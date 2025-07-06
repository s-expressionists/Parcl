(cl:in-package #:parcl.middle)

(defmethod remove-local-nickname ((client t) (nickname string) (package t))
  (let* ((nickname-string        nickname)
         (old-local-nicknames    (low:local-nicknames client package))
         (existing-nickname-pair (assoc nickname-string old-local-nicknames
                                        :test #'string=)))
    (cond ((null existing-nickname-pair)
           nil)
          (t
           (setf (low:local-nicknames client package)
                 (remove existing-nickname-pair old-local-nicknames
                         :test #'eq :count 1))
           ;; TODO: update nicknamed-by
           t))))
