(cl:in-package #:parcl.middle)

(defmethod add-local-nickname
    ((client t) (nickname string) (nicknamed-package t) (package t))
  (let* ((old-local-nicknames (low:local-nicknames client package))
         (existing-entry      (assoc nickname old-local-nicknames
                                     :test #'string=)))
    (cond ((null existing-entry)
           (setf (low:local-nicknames client package)
                 (list* (list nickname nicknamed-package) old-local-nicknames))
           ;; Since PACKAGE may have multiple nicknames fro
           ;; NICKNAMED-PACKAGE, only add PACKAGE if it is not already
           ;; there.
           (pushnew package (low:locally-nicknamed-by client nicknamed-package)
                    :test #'eq)
           t)
          ((eq nicknamed-package (second existing-entry))
           ;; existing pair with same name and same package => nothing to do
           nil) ; TODO: does the protocol specify what to return here?
          (t ; existing pair with same name but different package => error
           ;; FIXME: signal a continuable error.
           (error 'nickname-refers-to-different-package
                  :package package
                  :nickname nickname
                  :nicknamed-package nicknamed-package)
           nil))))
