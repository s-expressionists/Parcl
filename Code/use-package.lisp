(cl:in-package #:parcl)

(defun use-package (packages-to-use &optional (package-designator *package*))
  (let ((packages (if (listp packages-to-use)
                      (mapcar #'find-package packages-to-use)
                      (list (find-package packages-to-use))))
        (package (find-package package-designator)))
    (parcl-low:use-packages *client* package packages)))
