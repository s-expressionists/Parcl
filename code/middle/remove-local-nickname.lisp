(cl:in-package #:parcl.middle)

(defmethod remove-local-nickname ((client t) (nickname string) (package t))
  (let* ((old-local-nicknames (low:local-nicknames client package))
         (existing-entry      (find nickname old-local-nicknames
                                    :key #'first :test #'string=)))
    (if (null existing-entry)
        nil
        (let* ((new-local-nicknames      (remove existing-entry
                                                 old-local-nicknames
                                                 :test #'eq :count 1))
               (nicknamed-package        (second existing-entry)))
          (setf (low:local-nicknames client package) new-local-nicknames)
          ;; In theory, PACKAGE could have had multiple local
          ;; nicknames for NICKNAMED-PACKAGE so that even after
          ;; removing one local nicknames, NICKNAMED-PACKAGE might
          ;; still be locally nicknamed by PACKAGE.
          (when (null (find nicknamed-package new-local-nicknames
                            :key #'second :test #'eq))
            (let ((old-locally-nicknamed-by (low:locally-nicknamed-by
                                             client nicknamed-package)))
              (setf (low:locally-nicknamed-by client nicknamed-package)
                    (remove package old-locally-nicknamed-by
                            :test #'eq :count 1))))
          t))))
