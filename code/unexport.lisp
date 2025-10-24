(cl:in-package #:parcl)

(defun unexport (symbols &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (symbols symbol-list-designator))
    (loop for symbol in symbols
          do (parcl.middle:unexport client package symbol))
    t))
