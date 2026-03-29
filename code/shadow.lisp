(cl:in-package #:parcl)

(defun shadow (names &optional (package *package*))
  (with-resolved-designators (client (package package-designator)
                                     (names   string-list-designator))
    (loop for name in names
          do (parcl.middle:shadow client package name))
    t))
