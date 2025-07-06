(cl:in-package #:parcl.middle)

(defmethod shadowing-symbols ((client t) (package t))
  (let ((result '()))
    (flet ((consider-symbol (symbol status)
             (when (or (eq status :internal-shadowing) (eq status :external-shadowing))
               (push symbol result))))
      (parcl-low:map-symbol-entries client #'consider-symbol package)) ; TODO: use status filter argument
    result))
