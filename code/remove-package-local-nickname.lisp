(cl:in-package #:parcl)

(defun remove-package-local-nickname
    (old-nickname &optional(package *package*))
  (with-client-and-resolved-designators (client
                                         (package      package-designator)
                                         (old-nickname string-designator))
    (parcl.middle:remove-local-nickname client package old-nickname)))
