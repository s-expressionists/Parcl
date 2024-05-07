(cl:in-package #:parcl)

(defun package-shadowing-symbols (package-designator)
  (parcl-low:shadowing-symbols *client* (find-package package-designator)))
