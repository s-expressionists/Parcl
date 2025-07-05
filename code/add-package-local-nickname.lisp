(cl:in-package #:parcl)

(defun add-package-local-nickname
    (local-nickname actual-package &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package        package-designator)
                                         (actual-package package-designator)
                                         (local-nickname string-designator))
    (parcl-low:add-local-nickname
     client local-nickname actual-package package)))
