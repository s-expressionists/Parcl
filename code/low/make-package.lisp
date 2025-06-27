(cl:in-package #:parcl-low)

(defmethod make-package ((client t) (name t) (nicknames t) (used-packages t))
  (let ((result (make-package-object client name)))
    (setf (nicknames client result) nicknames)
    (use-packages client result used-packages)
    (parcl:store-package result name nicknames)
    result))
