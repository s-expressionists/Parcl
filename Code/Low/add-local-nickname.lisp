(cl:in-package #:parcl-low)

(defmethod add-local-nickname (client nickname nicknamed-package package)
  (let* ((nickname-string (string nickname))
         (existing-nickname-pair
           (assoc nickname-string
                  (local-nicknames client package)
                  :test #'string=)))
    (if (and (not (null existing-nickname-pair))
             (not (eq nicknamed-package (second existing-nickname-pair))))
        ;; FIXME: signal a continuable error.
        (error 'nickname-refers-to-different-package
               :nickname nickname-string
               :nicknamed-package nicknamed-package
               :package package)
        (progn (push (list nickname-string nicknamed-package)
                     (local-nicknames client package))
               (push package
                     (locally-nicknamed-by client nicknamed-package))))))
