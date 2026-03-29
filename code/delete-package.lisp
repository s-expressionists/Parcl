(cl:in-package #:parcl)

(defun delete-package (package)
  (with-resolved-designators (client (package package-designator/weak))
    (if (not (null package)) ; can be `nil' due to restart
        (parcl.middle:delete-package client package)
        nil)))
