(cl:in-package #:parcl)

(defun find-symbol (name &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (name    string-designator))
    (parcl.middle:find-symbol client package name)))
