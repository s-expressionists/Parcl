(cl:in-package #:parcl)

(defun find-symbol (name &optional (package *package*))
  (with-resolved-designators (client (package package-designator)
                                     (name    string-designator))
    (parcl.middle:find-symbol client package name)))
