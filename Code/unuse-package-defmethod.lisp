(cl:in-package #:parcl)

(defmethod unuse-package (client package package-to-unuse)
  (unless (member package-to-unuse (use-list client package)
                  :test #'eq)
    (error 'package-is-not-used
           :package package
           :package-to-unuse package-to-unuse))
  (setf (use-list client package)
        (delete package-to-unuse (use-list client package))))
