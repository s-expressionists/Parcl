(cl:in-package #:parcl)

(defmethod intern (client package name)
  (multiple-value-bind (symbol status)
      (find-symbol client package name)
    (if (null status)
        (let ((result (make-symbol client name package)))
          (add-internal-symbol client package name)
          (values result nil))
        (values symbol status))))
