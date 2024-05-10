(cl:in-package #:parcl)

(defun shadow (names &optional (package-designator *package*))
  (let ((package (find-package package-designator))
        (names (if (listp names) names (list names))))
    (loop for name in names
          do (parcl-low:shadow *client* package name))))

