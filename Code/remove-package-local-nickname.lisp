(cl:in-package #:parcl)

(defun remove-package-local-nickname
    (old-nickname &optional(package-designator *package*))
  (parcl-low:remove-local-nickname *client* old-nickname package-designator))
