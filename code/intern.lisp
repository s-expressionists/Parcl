(cl:in-package #:parcl)

(defun intern (name &optional (package *package*))
  (check-type name string)
  (with-resolved-designators (client (package package-designator))
    (parcl.middle:intern client package name)))
