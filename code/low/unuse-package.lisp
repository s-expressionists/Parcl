(cl:in-package #:parcl-low)

(defmethod unuse-package ((client t) (package t) (package-to-unuse t))
  (let ((use-list (use-list client package)))
    #+not-in-spec (unless (member package-to-unuse use-list :test #'eq)
      ;; TODO: recover?
      (error 'package-is-not-used :package          package
                                  :package-to-unuse package-to-unuse))
    (setf (use-list client package)
          (remove package-to-unuse use-list :count 1 :test #'eq)
          (used-by-list client package-to-unuse)
          (remove package (used-by-list client package-to-unuse) :count 1 :test #'eq)) ; TODO: alexandria:removef
    ;; TODO: return value
    ))
