(cl:in-package #:parcl)

(define-condition export-conflict ()
  nil)

(defmethod export (client package symbol)
  nil)