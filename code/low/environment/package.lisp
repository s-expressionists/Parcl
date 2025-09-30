(cl:in-package #:parcl-low-environment)

(defmethod low:find-package ((client client) (package-designator string))
  (assert (stringp package-designator))
  (let* ((environment (environment client))
         (entry       (env:lookup package-designator :package environment
                                                     :if-does-not-exist nil)))
    (if (null entry)
        nil
        (car entry))))

(defmethod (setf low:find-package) ((new-value t)
                                    (client client)
                                    (package-designator string))
  (assert (stringp package-designator))
  (let ((environment (environment client)))
    (setf (env:lookup package-designator :package environment)
          (cons new-value '()))
    new-value))

(defclass package (low:package env::equal-namespace)
  ((%name :accessor %name
          :initform nil)
   ;; (%nicknames
   ;;  :initarg :nicknames
   ;;  :initform '()
   ;;  :accessor nicknames)
   ;; ;; See the definition of the accessor above.
   ;; (%local-nicknames
   ;;  :initarg :local-nicknames
   ;;  :initform '()
   ;;  :accessor local-nicknames)
   ;; ;; See the definition of the accessor above.
   ;; (%locally-nicknamed-by
   ;;  :initarg :locally-nicknamed-by
   ;;  :initform '()
   ;;  :accessor locally-nicknamed-by)
   ;; (%use-list
   ;;  :initarg :use-list
   ;;  :initform '()
   ;;  :accessor use-list)
   ;; (%used-by-list
   ;;  :initarg :used-by-list
   ;;  :initform '()
   ;;  :accessor used-by-list)
   ;; (%symbol-table
   ;;  :initarg :symbol-table
   ;;  :reader symbol-table)
   ;; (%symbol-entries
   ;;  :initform '()
   ;;  :accessor symbol-entries)
   ))

(defmethod print-object ((object package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    ;; TODO(jmoringe): number of symbols etc., deletion status
    (format stream "~A" (%name object))))

;; TODO(jmoringe): should not be needed; better parcl-low:packagep client maybe-package
(defmethod low:find-package ((client client) (package-designator package))
  package-designator)

(defmethod initialize-instance :after ((instance package) &key name)
  (let* ((client      parcl:*client*)
         (environment (environment client)))
    (setf (env:lookup instance 'env:namespace environment) instance) ; TODO: could use a separate equal-namespace object
    (setf (low:name client instance) name)))

(defmethod low:make-package-object ((client client) (name string))
  (make-instance 'package :name name))

(defmethod low:name ((client client) (package package))
  (%name package))

(defmethod (setf low:name) ((new-value t)
                            (client    client)
                            (package   package))
  (setf (%name package) new-value))

(defmethod (setf low:name) :around ((new-value t)
                                    (client    client)
                                    (package   package))
  ;; TODO: wrong there is a separate protocol for this
  (let ((environment (environment client))
        (old-name    (%name package)))
    (unless (null old-name)
      (setf (env:lookup old-name :package environment) nil))
    (prog1
        (call-next-method)
      (setf (env:lookup new-value :package environment) (cons package '())))))

(macrolet ((define (accessor key)
             `(progn
                (defmethod ,accessor ((client  client)
                                      (package package))
                  (let* ((environment (environment client))
                         (name        (%name package))
                         (entry       (env:lookup name :package environment
                                                       :if-does-not-exist nil)))
                    ;; TODO: what if it is null?
                    (unless (null entry)
                      (destructuring-bind (package* . data) entry
                        (assert (eq package* package))
                        (getf data ,key)))))

                (defmethod (setf ,accessor) ((new-value t)
                                             (client    client)
                                             (package   package))
                  (let ((environment (environment client))
                        (name        (%name package)))
                    (env:make-or-update
                     name :package environment
                     (lambda () (error "should not happen"))
                     (lambda (existing container)
                       (declare (ignore container))
                       (destructuring-bind (package* . data) existing
                         (assert (eq package* package))
                         (let ((new-data (list* ,key new-value
                                                (alexandria:remove-from-plist data ,key))))
                           (values (cons package* new-data) t)))))))))
           )
  (define low:nicknames            :nicknames)
  (define low:use-list             :use-list)
  (define low:used-by-list         :used-by-list)
  (define low:local-nicknames      :local-nicknames)
  (define low:locally-nicknamed-by :locally-nicknamed-by))

(defmethod low::map-symbol-entries
    ((client client) (function t) (package package) &optional status)
  (let ((environment (environment client))
        ;; TODO: is this worth the effort? could just do the cases in the local function
        (visit       (cond ((null status)
                            (lambda (name entry container)
                              (declare (ignore name container))
                              (funcall function (car entry))))
                           ((symbolp status)
                            (lambda (name entry container)
                              (declare (ignore name container))
                              (when (eq (cdr entry) status)
                                (funcall function (car entry)))))
                           ((listp status)
                            (lambda (name entry container)
                              (declare (ignore name container))
                              (when (member (cdr entry) status :test #'eq)
                                (funcall function (car entry))))))))
    (env:map-entries visit package environment)))

#++ (defmethod low:map-symbols ((client   client)
                            (package  package)
                            (function t))
  (let* ((environment (environment client))
         #++ (name        (%name package))
         #++ (entry       (env:lookup name :package environment
                                       :if-does-not-exist nil)))
    (env:map-entries (lambda (name entry container)
                       (declare (ignore name container))
                       (funcall function (car entry)))
                     package environment)))

(defmethod low::symbol-entry ((client  client)
                              (name    string)
                              (package package))
  (let* ((environment (environment client))
         #++ (name        (%name package))
         (entry       (env:lookup name package environment
                                  :if-does-not-exist nil)))
    (if (null entry)
        (values nil nil)
        (destructuring-bind (symbol . status) entry
          (values symbol status)))))

(defmethod low::set-symbol-entry ((symbol  t)
                                  (status  t)
                                  (client  client)
                                  (name    string)
                                  (package package))
  (let ((environment (environment client)))
    (setf (env:lookup name package environment) (if (null status)
                                                    nil
                                                    (cons symbol status)))))

    (setf (env:lookup name package environment)


#+no (defmethod low:nicknames ((client client) (package package))
       )
