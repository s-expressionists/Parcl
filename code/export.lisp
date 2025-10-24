(cl:in-package #:parcl)

(defun export (symbols &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (symbols symbol-list-designator)
                                         (package package-designator))
    (loop for symbol in symbols
          do (parcl.middle:export client package symbol))
    t))
