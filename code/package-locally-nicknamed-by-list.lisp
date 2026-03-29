(cl:in-package #:parcl)

(defun package-locally-nicknamed-by-list (package)
  (with-resolved-designators (client (package package-designator))
    (parcl.low:locally-nicknamed-by client package)))
