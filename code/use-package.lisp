(cl:in-package #:parcl)

(defun use-package (packages-to-use &optional (package *package*))
  (with-resolved-designators (client (package         package-designator)
                                     (packages-to-use package-list-designator))
    (parcl.middle:use-packages client package packages-to-use)))
