(cl:in-package #:parcl.middle)

(defmethod add-local-nickname
    ((client t) (nickname t) (nicknamed-package t) (package t))
  (let* ((nickname-string (string nickname)) ; TODO: designator should already be handled
         (existing-nickname-pair
           (assoc nickname-string
                  (low:local-nicknames client package)
                  :test #'string=)))
    (if (and (not (null existing-nickname-pair))
             (not (eq nicknamed-package (second existing-nickname-pair))))
        ;; FIXME: signal a continuable error.
        (error 'nickname-refers-to-different-package
               :nickname nickname-string
               :nicknamed-package nicknamed-package
               :package package)
        (progn (push (list nickname-string nicknamed-package)
                     (low:local-nicknames client package))
               (push package
                     (low:locally-nicknamed-by client nicknamed-package))))))
