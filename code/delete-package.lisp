(cl:in-package #:parcl)

(defun delete-package (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (if (not (null package))
        (parcl-low:delete-package client package)
        nil)))

(setf (documentation 'delete-package 'function)
      (format nil
              "Syntax: delete-package package-designator~@
               ~@
               This function returns a generalized boolean. TODO"))
