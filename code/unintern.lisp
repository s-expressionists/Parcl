(cl:in-package #:parcl)

(defun unintern (symbol &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (symbol  symbol))
    (parcl.middle:unintern client package symbol)))
