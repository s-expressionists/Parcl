(cl:in-package #:parcl)

(defun package-use-list (package)
  (with-resolved-designators (client (package package-designator))
    (parcl.low:use-list client package)))
