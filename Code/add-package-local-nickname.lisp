(cl:in-package #:parcl)

(defun add-package-local-nickname
    (local-nickname actual-package &optional package-designator)
  (parcl-low:add-local-nickname
   *client* local-nickname
   (find-package actual-package)
   (find-package package-designator)))
