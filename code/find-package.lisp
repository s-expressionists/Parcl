(cl:in-package #:parcl)

(defun find-package (name)
  (let ((client *client*))
    (multiple-value-bind (package-or-name packagep)
        (check-package-designator client name)
      (cond (packagep
             package-or-name)
            ((boundp '*package*)
             (parcl.middle:find-package-using-package
              client *package* package-or-name))
            (t
             (parcl.middle:find-package-using-package
              client nil package-or-name))))))
