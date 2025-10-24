(cl:in-package #:parcl)

(defun package-use-list (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (parcl.low:use-list client package)))
