(cl:in-package #:parcl)

(defun unintern (symbol &optional (package-designator *package*))
  (let ((package (find-package-or-error package-designator)))
    (parcl-low:unintern *client* package symbol)))

(setf (documentation 'unintern 'function)
      (format nil
              "Syntax: unintern string &optional package-designator~@
               ~@
               This function returns a generalized Boolean. TODO"))
