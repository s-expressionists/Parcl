(cl:in-package #:parcl)

(defmethod shadow (client package name)
  (multiple-value-bind (symbol status)
      (find-symbol client package name)
    (let ((symbol (case status
                    ((:internal :external)
                     symbol)
                    (otherwise
                     (make-symbol client name package)))))
      (add-internal-symbol client package symbol)
      (add-shadowing-symbol client package symbol))))
