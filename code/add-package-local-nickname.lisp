(cl:in-package #:parcl)

(defun add-package-local-nickname
    (local-nickname nicknamed-package &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package           package-designator)
                                         (nicknamed-package package-designator)
                                         (local-nickname    string-designator))
    (parcl.middle:add-local-nickname
     client package local-nickname nicknamed-package)
    package))
