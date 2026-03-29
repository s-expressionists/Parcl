(cl:in-package #:parcl)

(defun unuse-package (packages-to-unuse &optional (package *package*))
  (with-resolved-designators (client (packages-to-unuse package-list-designator)
                                     (package           package-designator))
    (loop for package-to-unuse in packages-to-unuse
          do (parcl.middle:unuse-package client package package-to-unuse))
    t))
