(cl:in-package #:parcl)

(defun package-nicknames (package)
  (with-resolved-designators (client (package package-designator))
    (parcl.low:nicknames client package)))
