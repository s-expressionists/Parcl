(cl:in-package #:parcl.implementation.class)

(defmethod parcl.low:packagep ((client package-class-mixin) (package package))
  t)

(macrolet ((define (accessor &optional (client-class  'package-class-mixin)
                                       (package-class 'package))
             (let ((low-accessor (intern (string accessor) '#:parcl.low)))
               `(progn
                  (defmethod ,low-accessor ((client  ,client-class)
                                            (package ,package-class))
                    (,accessor package))

                  (defmethod (setf ,low-accessor)
                      ((new-value t) (client client) (package package))
                    (setf (,accessor package) new-value))))))
  (define name)
  (define nicknames)
  (define local-nicknames      parcl.middle:local-nicknames-mixin
                               local-nicknames-mixin)
  (define locally-nicknamed-by parcl.middle:local-nicknames-mixin
                               local-nicknames-mixin)
  (define use-list)
  (define used-by-list)
  ; (define documentation)
  )

;;; Package-symbol relation functions

(declaim (inline decode-status encode-status))
(defun decode-status (encoded-status)
  (values (if (logbitp 0 encoded-status) :external :internal)
          (logbitp 1 encoded-status)))

(defun encode-status (export-status shadow-status)
  (let ((result 0))
    (setf (ldb (byte 1 0) result) (ecase export-status
                                    (:internal 0)
                                    (:external 1))
          (ldb (byte 1 1) result) (if shadow-status 1 0))
    result))

(defmethod parcl.low:map-symbol-entries
    ((client package-class-mixin) (function t) (package package)
     &optional status)
  (maphash                           ; TODO: alexandria maphash-values
   (lambda (name entry)
     (declare (ignore name))
     (destructuring-bind (symbol . encoded-status) entry
       (multiple-value-bind (export-status shadow-status)
           (decode-status encoded-status)
         (when (or (null status) (eq export-status status))
           (funcall function symbol export-status shadow-status)))))
   (%entries package)))

(defmethod parcl.low:symbol-entry
    ((client package-class-mixin) (name t) (package package))
  (let ((entry (gethash name (%entries package))))
    (if (null entry)
        (values nil nil nil)
        (let ((symbol         (car entry))
              (encoded-status (cdr entry)))
          (multiple-value-bind (export-status shadow-status)
              (decode-status encoded-status)
            (values symbol export-status shadow-status))))))

(defmethod parcl.low:set-symbol-entry ((new-symbol        t)
                                       (new-export-status t)
                                       (new-shadow-status t)
                                       (client            package-class-mixin)
                                       (name              t)
                                       (package           package))
  (let ((entries (%entries package)))
    (if (null new-export-status)
        (remhash name entries)
        (setf (gethash name entries)
              (cons new-symbol (encode-status new-export-status
                                              new-shadow-status))))))

;;;

(defmethod parcl.low:make-package-object ((client package-class-mixin) (name t))
  (make-instance 'package :name name))

(defmethod parcl.low:make-package-object ((client client-with-local-nicknames)
                                          (name   t))
  (make-instance 'package-with-local-nicknames :name name))
