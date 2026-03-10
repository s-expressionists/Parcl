(cl:in-package #:parcl.middle)

(defmethod unuse-package ((client t) (package t) (package-to-unuse t))
  (let ((use-list (low:use-list client package)))
    (cond ((member package-to-unuse use-list :test #'eq)
           (setf (low:use-list client package)
                 (delete package-to-unuse use-list :count 1 :test #'eq))
           (a:deletef (low:used-by-list client package-to-unuse) package
                      :count 1 :test #'eq)
           t)
          (t
           nil))))
