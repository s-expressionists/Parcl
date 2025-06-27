(cl:in-package #:parcl)

(defun find-package (package-designator)
  (parcl-low:find-package *client* package-designator))
