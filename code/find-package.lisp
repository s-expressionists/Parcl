(cl:in-package #:parcl)

(defun find-package (name)
  (with-client-and-resolved-designators (client
                                         (name package-designator/check))
    (parcl-low:find-package client name)))
