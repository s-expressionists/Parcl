(cl:in-package #:parcl)

(defun package-name (package)
  (with-resolved-designators (client (package package-designator/weak))
    (parcl.low:name client package)))
