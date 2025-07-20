(cl:in-package #:parcl)

(defun list-all-packages ()
  (parcl.middle:packages *client*))
