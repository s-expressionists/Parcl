(cl:in-package #:parcl)

(defun find-all-symbols (name)
  (with-client-and-resolved-designators (client
                                         (name string-designator))
    (parcl.middle:find-symbols client name)))
