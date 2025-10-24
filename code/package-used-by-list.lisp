(cl:in-package #:parcl)

(defun package-used-by-list (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (parcl.low:used-by-list client package)))
