(cl:in-package #:parcl)

(defun package-local-nicknames (package)
  (with-resolved-designators (client (package package-designator))
    (parcl.low:local-nicknames client package)))
