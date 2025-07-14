(cl:in-package #:parcl.middle)

(defmethod find-package-using-package ((client t) (package null) (name string))
  (low:find-package client name))

(defmethod find-package-using-package ((client t) (package t) (name string))
  (let ((nickname-entry (find name (low:local-nicknames client package)
                              :key #'first :test #'string=)))
    (if (not (null nickname-entry))
        (second nickname-entry)
        (find-package-using-package client nil name))))
