(cl:in-package #:parcl)

(defun rename-package (package new-name &optional new-nicknames)
  (with-client-and-resolved-designators (client
                                         (package       package-designator)
                                         (new-name      package-name-designator)
                                         (new-nicknames string-designator-list))
    ;; PACKAGE can be `null' due to error recovery.
    (if (not (null package))
        (parcl.middle:rename-package client package new-name new-nicknames)
        nil)))
