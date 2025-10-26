(cl:in-package #:parcl.middle)

(defmethod shadowing-symbols ((client t) (package t))
  (let ((result '()))
    (flet ((consider-symbol (symbol export-status shadow-status)
             (declare (ignore export-status))
             (when shadow-status
               (push symbol result))))
      (parcl.low:map-symbol-entries client #'consider-symbol package)) ; TODO: use status filter argument
    result))
