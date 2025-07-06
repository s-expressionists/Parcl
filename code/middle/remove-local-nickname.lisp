(cl:in-package #:parcl-low)

(defmethod remove-local-nickname (client nickname package)
  (let* ((nickname-string (string nickname))
         (existing-nickname-pair
           (assoc nickname-string
                  (local-nicknames client package)
                  :test #'string=)))
    (if (null existing-nickname-pair)
        nil
        (progn (setf (local-nicknames client package)
                     (remove existing-nickname-pair
                             (local-nicknames client package)))
               t))))
