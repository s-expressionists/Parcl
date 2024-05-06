(cl:in-package #:parcl)

(defun unuse-pacakge
    (packages-to-unuse &optional (package-designator *package*))
  (let ((packages (if (listp packages-to-unuse)
                      (mapcar #'find-package packages-to-unuse)
                      (list (find-package packages-to-unuse))))
        (package (find-package package-designator)))
    (loop for package-to-unuse in packages
          do (parcl-low:unuse-package *client* package package-to-unuse))))
