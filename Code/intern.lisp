(cl:in-package #:parcl)

(defun intern (name &optional (package-designator *package*))
  (parcl-low:intern *client* (find-package package-designator) name))
