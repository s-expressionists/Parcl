(cl:in-package #:parcl)

(defun add-package-local-nickname
    (local-nickname actual-package &optional (package-designator *package*))
  (parcl-low:add-local-nickname
   *client* local-nickname
   (find-package-or-error actual-package)
   (find-package-or-error package-designator)))
