(cl:in-package #:parcl-low-class)

(defmethod parcl.low:packagep ((client client) (package package))
  t)

(macrolet ((define (accessor)
             (let ((low-accessor (intern (string accessor) '#:parcl.low)))
               `(progn
                  (defmethod ,low-accessor ((client client) (package package))
                    (,accessor package))

                  (defmethod (setf ,low-accessor)
                      ((new-value t) (client client) (package package))
                    (setf (,accessor package) new-value))))))
  (define name)
  (define nicknames)
  (define local-nicknames)
  (define locally-nicknamed-by)
  (define use-list)
  (define used-by-list)
  ; (define documentation)
  )

;;; Package-symbol relation functions

(defmethod parcl.low:map-symbol-entries
    ((client client) (function t) (package package) &optional status)
  (declare (ignore status))
  (maphash (lambda (name entry)
             (declare (ignore name)) ; TODO: alexandria maphash-values
             (destructuring-bind (symbol . (export-status . shadow-status))
                 entry
               (funcall function symbol export-status shadow-status)))
           (%entries package)))

(defmethod parcl.low:symbol-entry ((client client) (name t) (package package))
  (let ((entry (gethash name (%entries package))))
    (if (null entry)
        (values nil nil nil)
        (values (car entry) (cadr entry) (cddr entry)))))

(defmethod parcl.low:set-symbol-entry ((new-symbol        t)
                                       (new-export-status t)
                                       (new-shadow-status t)
                                       (client            client)
                                       (name              t)
                                       (package           package))
  (let ((entries (%entries package)))
    (if (null new-export-status)
        (remhash name entries)
        (setf (gethash name entries)
              (cons new-symbol (cons new-export-status new-shadow-status))))))

;;;

(defmethod parcl.low:make-package-object ((client client) (name t))
  (make-instance 'package :name name))
