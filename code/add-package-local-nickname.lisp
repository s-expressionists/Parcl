(cl:in-package #:parcl)

(defun add-package-local-nickname
    (local-nickname actual-package &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package        package-designator)
                                         (actual-package package-designator)
                                         (local-nickname string-designator))
    (parcl.middle:add-local-nickname
     client package local-nickname actual-package)))
