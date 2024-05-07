(cl:in-package #:parcl)

(defun package-name (package-designator)
  (parcl-low:name *client* (find-package package-designator)))
