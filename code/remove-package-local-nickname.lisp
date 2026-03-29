(cl:in-package #:parcl)

(defun remove-package-local-nickname
    (local-nickname &optional(package *package*))
  (with-resolved-designators (client (package        package-designator)
                                     (local-nickname string-designator))
    (parcl.middle:remove-local-nickname client package local-nickname)))
