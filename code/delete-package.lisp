(cl:in-package #:parcl)

(defun delete-package (package-designator)
  ;; TODO: check undeleted
  (let ((package (find-undeleted-package-or-error package-designator)))
    (if (not (null package))
        (parcl-low:delete-package *client* package)
        nil)))

(setf (documentation 'delete-package 'function)
      (format nil
              "Syntax: delete-package package-designator~@
               ~@
               This function returns a generalized boolean. TODO"))
