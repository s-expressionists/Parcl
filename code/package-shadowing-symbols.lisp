(cl:in-package #:parcl)

(defun package-shadowing-symbols (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (parcl.middle:shadowing-symbols client package)))
