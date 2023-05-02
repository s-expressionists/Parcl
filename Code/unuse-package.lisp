(cl:in-package #:parcl)

(defmethod unuse-package (client package package-to-unuse)
  (unless (member package-to-unuse (use-list package)
                  :test #'eq)
    (error 'package-is-not-used
           :package package
           :package-to-unuse package-to-unuse))
  (setf (use-list package)
        (delete package-to-unuse (use-list package))))
