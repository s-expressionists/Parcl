(cl:in-package #:parcl.implementation.environment)

(defclass package (low:package env::equal-namespace)
  ())

(defmethod print-object ((object package) stream)
  (let ((name (low:name parcl:*client* object)))
    (print-unreadable-object (object stream :type t :identity t)
      ;; TODO(jmoringe): number of symbols etc., deletion status
      (format stream "~A" name))))

(defmethod initialize-instance :after ((instance package) &key name)
  (let* ((client      parcl:*client*)
         (environment (environment client)))
    (setf (env:lookup instance 'env:namespace environment) instance ; TODO: could use a separate equal-namespace object
          (env:lookup instance :package-state environment) `(:name ,name))))

;;;; Low module protocol

;;; Package functions

(defmethod low:packagep ((client client) (package package))
  t)

(macrolet ((define (accessor key)
             `(progn
                (defmethod ,accessor ((client client) (package package))
                  (let* ((environment (environment client))
                         (entry       (env:lookup package :package-state environment)))
                    (getf entry ,key)))

                (defmethod (setf ,accessor) ((new-value t)
                                             (client    client)
                                             (package   package))
                  (let ((environment (environment client)))
                    (env:make-or-update
                     package :package-state environment
                     (lambda () (error "should not happen"))
                     (lambda (existing container)
                       (declare (ignore container))
                       (let ((new-data (list* ,key new-value
                                              (alexandria:remove-from-plist existing ,key))))
                         (values new-data t)))))))))
  (define low:name                 :name)
  (define low:nicknames            :nicknames)
  (define low:use-list             :use-list)
  (define low:used-by-list         :used-by-list)
  (define low:local-nicknames      :local-nicknames)
  (define low:locally-nicknamed-by :locally-nicknamed-by))

(defmethod low:make-package-object ((client client) (name string))
  (make-instance 'package :name name))

;;; Symbol functions

(defmethod low:map-symbol-entries
    ((client client) (function t) (package package) &optional status)
  (let ((environment (environment client)))
    (env:map-entries
     (lambda (name entry container)
       (declare (ignore name container))
       (destructuring-bind (symbol . (export-status . shadow-status)) entry
         (when (or (null status) (eq export-status status))
           (funcall function symbol export-status shadow-status))))
     package environment)))

(defmethod low:symbol-entry ((client client) (name string) (package package))
  (let* ((environment (environment client))
         #++ (name        (%name package))
         (entry       (env:lookup name package environment
                                  :if-does-not-exist nil)))
    (if (null entry)
        (values nil nil)
        (destructuring-bind (symbol . (export-status . shadow-status)) entry
          (values symbol export-status shadow-status)))))

(defmethod low:set-symbol-entry ((symbol        t)
                                 (export-status t)
                                 (shadow-status t)
                                 (client        client)
                                 (name          string)
                                 (package       package))
  (let ((environment (environment client)))
    (setf (env:lookup name package environment)
          (if (null export-status)
              env::+unbound+ ; TODO: there should be a better way
              (cons symbol (cons export-status shadow-status))))))

;;; Environment functions

(defmethod low:packages ((client client))
  (let ((environment (environment client))
        (result      '()))
    (env:map-entries (lambda (name entry container)
                       (declare (ignore name container))
                       (push entry result))
                     :package environment)
    ;; `t' indicates that the returned list is fresh.
    (values result t)))

(defmethod low:find-package ((client client) (name string))
  (let ((environment (environment client)))
    (env:lookup name :package environment :if-does-not-exist nil)))

(defmethod (setf low:find-package) ((new-value t) (client client) (name string))
  (let ((environment (environment client)))
    (setf (env:lookup name :package environment) (if (null new-value)
                                                     env::+unbound+ ; TODO: there should be a better way
                                                     new-value)))
  new-value)
