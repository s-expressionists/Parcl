(cl:in-package #:parcl)

(defun create-length-categories ()
  (loop with categories = (make-array 39 :initial-element '())
        for symbol being the external-symbols
          of (cl:find-package "COMMON-LISP")
        for name = (symbol-name symbol)
        do (push name (aref categories (length name)))
        finally (return categories)))
