(cl:in-package #:parcl)

(defun packagep (package)
  (parcl-low:packagep *client* package))
