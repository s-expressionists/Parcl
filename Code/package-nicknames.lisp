(cl:in-package #:parcl)

(defun package-nicknames (package-designator)
  (parcl-low:nicknames *client* (find-package package-designator)))
