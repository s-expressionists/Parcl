(let ((p (make-package "P")))
  (delete-package p)
  (find-package p))
