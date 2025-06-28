(cl:in-package #:parcl)

(defun remove-package-local-nickname
    (old-nickname &optional(package-designator *package*))
  (let ((package (find-package-or-error package-designator)))
    (parcl-low:remove-local-nickname *client* old-nickname package)))
