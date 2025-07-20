(cl:in-package #:parcl.middle)

(defmethod find-package-using-package ((client t) (package t) (name string))
  (low:find-package client name))
