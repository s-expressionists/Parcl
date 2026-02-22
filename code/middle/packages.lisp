(cl:in-package #:parcl.middle)

(defmethod packages ((client t))
  (multiple-value-bind (packages fresh-lisp-p) (parcl.low:packages client)
    (if fresh-lisp-p
        packages
        (copy-list packages))))
