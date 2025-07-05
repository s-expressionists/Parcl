(cl:in-package #:parcl)

(defun unintern (symbol &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (symbol  symbol))
    (parcl-low:unintern client package symbol)))

(setf (documentation 'unintern 'function)
      (format nil
              "Syntax: unintern string &optional package-designator~@
               ~@
               This function returns a generalized Boolean. TODO"))
