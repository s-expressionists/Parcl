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

;;;; Middle

(defun translate-package-name-occupied (condition)
  (let* ((name             (first (simple-condition-format-arguments
                                   condition)))
         (existing-package (find-package name)))
   (error 'parcl:package-name-occupied-error
          :new-name         name
          :existing-package existing-package )))

(defun translate-name-conflict (condition)
  (let ((conflicts '()))
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

(defmacro with-translated-name-conflict (() &body body)
  `(handler-bind ((sb-ext:name-conflict #'translate-name-conflict))
     ,@body))

(defmethod middle:use-packages ((client          client)
                                (package         package)
                                (packages-to-use t))
  (with-translated-name-conflict ()
    (use-package packages-to-use package)))

(defmethod middle:unuse-package ((client            client)
                                 (package           package)
                                 (packages-to-unuse t))
  (unuse-package packages-to-unuse package))

(defmethod middle:add-local-nickname ((client            client)
                                      (package           package)
                                      (nickname          string)
                                      (nicknamed-package package))
  (sb-ext:add-package-local-nickname nickname nicknamed-package package))

(defmethod middle:remove-local-nickname ((client   client)
                                         (package  package)
                                         (nickname string))
  (sb-ext:remove-package-local-nickname nickname package))

(defmethod middle:shadowing-symbols ((client client) (package package))
  (package-shadowing-symbols package))

(defmethod middle:find-symbol ((client client) (package package) (name t))
  (find-symbol name package))

(defmethod middle:intern ((client client) (package package) (name t))
  (intern name package))

(defmethod middle:unintern ((client client) (package package) (symbol t))
  (with-translated-name-conflict ()
    (unintern symbol package)))

(defmethod middle:export ((client client) (package package) (symbol t))
  (with-translated-name-conflict ()
    (export symbol package)))

(defmethod middle:unexport ((client client) (package package) (symbol t))
  (with-translated-name-conflict ()
    (unexport symbol package)))

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
  (handler-bind ((package-error #'translate-package-name-occupied))
    (make-package name :nicknames nicknames :use used-packages)))

(defmethod middle:delete-package ((client client) (package package))
  (delete-package package))

(defmethod middle:rename-package
    ((client client) (package package) (new-name t) (new-nicknames t))
  (with-translated-name-conflict ()
    (rename-package package new-name new-nicknames)))

;;;; Low

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
  (sb-ext:package-local-nicknames package))

(defmethod low:locally-nicknamed-by ((client client) (package package))
  (sb-ext:package-locally-nicknamed-by-list package))

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

(defmethod low:map-symbol-entries ((client client) (function t) (package package) &optional status)
  (let ((shadowing-symbols (package-shadowing-symbols package)))
    (do-symbols (symbol package)
      (multiple-value-bind (symbol status)
          (find-symbol (symbol-name symbol) package)
        (when (member status '(:internal :external))
          (let ((shadowing? (member symbol shadowing-symbols :test #'eq)))
            (funcall function symbol status shadowing?)))))))

;;;

#++ (defmethod low:find-package ((client client) (name string))
  (find-package name))
