(cl:defpackage #:parcl.implementation.native
  (:use
   #:cl)

  (:local-nicknames
   (#:a      #:alexandria)
   (#:middle #:parcl.middle)
   (#:low    #:parcl.low))

  (:export
   #:client))

(cl:in-package #:parcl.implementation.native)

;;;; Client

(defclass client () ())

;;;; Implementation of middle module protocols

(defun translate-package-name-occupied (condition)
  (let* ((name             (first (simple-condition-format-arguments
                                   condition)))
         (existing-package (find-package name)))
   (error 'parcl:package-name-occupied-error
          :new-name         name
          :existing-package existing-package)))

(defun translate-name-conflict (condition)
  (let ((conflicts '()))
    #+sbcl
    (loop :for symbol        :in (sb-ext:name-conflict-symbols condition)
          :for name          =   (symbol-name symbol)
          :for other-package =   (symbol-package symbol)
          :for conflict      =   (or (find name conflicts
                                           :test #'string= :key #'car)
                                     (let ((conflict (cons name '())))
                                       (push conflict conflicts)
                                       conflict))
          :do (push (cons symbol other-package) (cdr conflict)))
    (error 'parcl:symbol-conflicts-error ; TODO: rename to name conflict
           :package   (package-error-package condition)
           :conflicts conflicts)))

(defmacro with-translated-restarts ((&rest restart-mapping) &body body)
  `(restart-case
       (progn ,@body)
     ,@(loop :for (restart native-restart) :in restart-mapping
             :collect `(,restart ()
                         (invoke-restart ',native-restart)))))

(defmacro with-translated-name-conflict ((&rest restart-mapping) &body body)
  `(restart-case
       (handler-bind ((#+sbcl sb-ext:name-conflict
                       #+ccl  (or ccl::unintern-conflict-error
                                  ccl::use-package-conflict-error
                                  ccl::export-conflict-error)
                       (lambda (condition)
                         (with-translated-restarts (,@restart-mapping)
                           (translate-name-conflict condition)))))
         ,@body)
     (abort () nil)))

(defmethod middle:use-packages ((client          client)
                                (package         package)
                                (packages-to-use t))
  ;; Implementations usually don't have specialized conditions we
  ;; could recognize or don't signal errors at all.  So we repeat the
  ;; generic logic here.
  (let ((keyword-package (load-time-value (find-package "KEYWORD"))))
    (when (eq package keyword-package)
      (error 'parcl:used-by-keyword-package-forbidden-error
             :package keyword-package))
    (when (find keyword-package packages-to-use :test #'eq)
      (error 'parcl:using-keyword-package-forbidden-error :package package)))
  (with-translated-name-conflict ((parcl:unintern #+sbcl sb-impl::take-new)
                                  (parcl:shadow   #+sbcl sb-impl::keep-old))
    (use-package packages-to-use package)))

(defmethod middle:unuse-package ((client            client)
                                 (package           package)
                                 (packages-to-unuse t))
  (unuse-package packages-to-unuse package))

(defmethod middle:add-local-nickname ((client            client)
                                      (package           package)
                                      (nickname          string)
                                      (nicknamed-package package))
  #+sbcl (handler-bind
             ((package-error
                (lambda (condition)
                  (declare (ignore condition))
                  (with-translated-restarts
                      ((parcl::use-new-nicknamed-package  sb-impl::change-nick)
                       (parcl::keep-old-nicknamed-package sb-impl::keep-old))
                   (error 'parcl:nickname-refers-to-different-package-error
                          :package           package
                          :nickname          nickname
                          :nicknamed-package nicknamed-package)))))
           (sb-ext:add-package-local-nickname nickname nicknamed-package package))
  #+ccl  (ccl:add-package-local-nickname    nickname nicknamed-package package))

(defmethod middle:remove-local-nickname ((client   client)
                                         (package  package)
                                         (nickname string))
  #+sbcl (sb-ext:remove-package-local-nickname nickname package)
  #+ccl  (ccl:remove-package-local-nickname    nickname package))

(defmethod middle:shadowing-symbols ((client client) (package package))
  (package-shadowing-symbols package))

(defmethod middle:find-symbol ((client client) (package package) (name t))
  (find-symbol name package))

(defmethod middle:intern ((client client) (package package) (name t))
  (intern name package))

(defmethod middle:unintern ((client client) (package package) (symbol t))
  (with-translated-name-conflict ((parcl::abort-operation abort))
    (unintern symbol package)))

(defmethod middle:export ((client client) (package package) (symbol t))
  (with-translated-name-conflict ((parcl:unintern            #+sbcl sb-impl::take-new)
                                  (parcl:shadow              #+sbcl sb-impl::keep-old)
                                  (parcl::make-new-shadowing #+sbcl sb-impl::take-new)
                                  (parcl::make-old-shadowing #+sbcl sb-impl::keep-old)
                                  (parcl::do-not-export      abort))
    (export symbol package)))

(defmethod middle:unexport ((client client) (package package) (symbol t))
  (flet ((unexport-forbidden (package symbol)
           (restart-case
               (error 'parcl:unexport-forbidden-for-system-package-error
                      :package            package
                      :symbol-to-unexport symbol)
             (#1=parcl::do-nothing ()
               :report (lambda (stream)
                         (parcl::report-restart '#1# stream 'parcl:unexport)
                         (return-from middle:unexport nil))))))
    #+sbcl (when (eq package (load-time-value (find-package "KEYWORD")))
             (unexport-forbidden package symbol))
    (with-translated-name-conflict ()
      (handler-bind (#+sbcl
                     (sb-ext:package-locked-error
                       (lambda (condition)
                         (let ((package (package-error-package condition)))
                           (unexport-forbidden package symbol)))))
        (unexport symbol package)))))

(defmethod middle:import ((client client) (package package) (symbol t))
  (with-translated-name-conflict ()
    (import symbol package)))

(defmethod middle:shadowing-import
    ((client client) (package package) (symbol t))
  (shadowing-import symbol package))

(defmethod middle:shadow ((client client) (package package) (name t))
  (shadow name package))

(defmethod middle:find-package-using-package
    ((client client) (package null) (name string))
  (find-package name))

(defmethod middle:find-package-using-package
    ((client client) (package package) (name string))
  (let ((*package* package))
    (find-package name)))

(defmethod middle:make-package
    ((client client) (name t) (nicknames t) (used-packages t))
  ;; TODO: could be problem with used packages as well
  (handler-bind ((package-error
                   (lambda (condition)
                     (with-translated-restarts
                         ((parcl::return-existing #+sbcl continue))
                       (translate-package-name-occupied condition)))))
    (make-package name :nicknames nicknames :use used-packages)))

(defmethod middle:delete-package ((client client) (package package))
  (delete-package package))

(defmethod middle:rename-package
    ((client client) (package package) (new-name t) (new-nicknames t))
  (with-translated-name-conflict ()
    (rename-package package new-name new-nicknames)))

;;;; Implementation of low module protocols

;;; Symbol functions

(defmethod low:symbolp ((client client) (object symbol))
  t)

(defmethod low:symbol-name ((client client) (symbol symbol))
  (symbol-name symbol))

(defmethod low:symbol-package ((client client) (symbol symbol))
  (symbol-package symbol))

(defmethod low:make-symbol ((client client) (name t) (package t))
  (let ((symbol (make-symbol name)))
    (unless (null package)
      ;; If we get here, NAME does not designate a present symbol in
      ;; PACKAGE, so `import' cannot cause a conflict.
      (if (eq (nth-value 1 (find-symbol name package)) :inherited)
          (shadowing-import symbol package)
          (import symbol package)))
    symbol))

;;; Package functions

(defmethod low:packagep ((client client) (object package))
  t)

(defmethod low:name ((client client) (package package))
  (package-name package))

(defmethod low:nicknames ((client client) (package package))
  (package-nicknames package))

(defmethod low:local-nicknames ((client client) (package package))
  #+sbcl (sb-ext:package-local-nicknames package)
  #+ccl  (ccl:package-local-nicknames    package))

(defmethod low:locally-nicknamed-by ((client client) (package package))
  #+sbcl (sb-ext:package-locally-nicknamed-by-list package)
  #+ccl  (ccl:package-locally-nicknamed-by-list    package))

(defmethod low:use-list ((client client) (package package))
  (package-use-list package))

(defmethod low:used-by-list ((client client) (package package))
  (package-used-by-list package))

;;;

(defmethod low:symbol-entry ((client client) (name t) (package package))
  (multiple-value-bind (symbol status)
      (find-symbol name package)
    (when (member status '(:internal :external))
      (let* ((shadowing-symbols (package-shadowing-symbols package))
             (shadowing?        (member symbol shadowing-symbols :test #'eq)))
        (values symbol status shadowing?)))))

(defmethod low:map-symbol-entries ((client client) (function t) (package package)
                                   &optional status)
  (let ((shadowing-symbols (package-shadowing-symbols package)))
    (do-symbols (symbol package)
      (multiple-value-bind (symbol actual-status)
          (find-symbol (symbol-name symbol) package)
        (when (or (eq actual-status status)
                  (member actual-status '(:internal :external)))
          (let ((shadowing? (member symbol shadowing-symbols :test #'eq)))
            (funcall function symbol actual-status shadowing?)))))))

;;;

(defmethod low:packages ((client client))
  (values (list-all-packages) t))

#++ (defmethod low:find-package ((client client) (name string))
  (find-package name))
