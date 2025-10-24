(cl:in-package #:parcl.middle)

(defclass local-nicknames-mixin () ())

(defmethod find-package-using-package ((client  local-nicknames-mixin)
                                       (package null)
                                       (name    string))
  (low:find-package client name))

(defmethod find-package-using-package ((client  local-nicknames-mixin)
                                       (package t)
                                       (name    string))
  (let ((nickname-entry (find name (low:local-nicknames client package)
                              :key #'first :test #'string=)))
    (if (not (null nickname-entry))
        (second nickname-entry)
        (find-package-using-package client nil name))))

(defmethod add-local-nickname ((client            local-nicknames-mixin)
                               (package           t)
                               (nickname          string)
                               (nicknamed-package t))
  (let* ((old-local-nicknames (low:local-nicknames client package))
         (existing-entry      (assoc nickname old-local-nicknames
                                     :test #'string=)))
    (cond ((null existing-entry)
           (setf (low:local-nicknames client package)
                 (acons nickname nicknamed-package old-local-nicknames))
           ;; Since PACKAGE may have multiple nicknames fro
           ;; NICKNAMED-PACKAGE, only add PACKAGE if it is not already
           ;; there.
           (pushnew package (low:locally-nicknamed-by client nicknamed-package)
                    :test #'eq)
           t)
          ((eq nicknamed-package (cdr existing-entry))
           ;; existing pair with same name and same package => nothing to do
           nil) ; TODO: does the protocol specify what to return here?
          (t ; existing pair with same name but different package => error
           ;; FIXME: signal a continuable error.
           (error 'nickname-refers-to-different-package-error
                  :package           package
                  :nickname          nickname
                  :nicknamed-package nicknamed-package)
           nil))))

(defmethod remove-local-nickname ((client   local-nicknames-mixin)
                                  (package  t)
                                  (nickname string))
  (let* ((old-local-nicknames (low:local-nicknames client package))
         (existing-entry      (assoc nickname old-local-nicknames
                                     :test #'string=)))
    (if (null existing-entry)
        nil
        (let* ((new-local-nicknames (remove existing-entry old-local-nicknames
                                            :test #'eq :count 1))
               (nicknamed-package   (cdr existing-entry)))
          (setf (low:local-nicknames client package) new-local-nicknames)
          ;; In theory, PACKAGE could have had multiple local
          ;; nicknames for NICKNAMED-PACKAGE so that even after
          ;; removing one local nicknames, NICKNAMED-PACKAGE might
          ;; still be locally nicknamed by PACKAGE.
          (when (null (rassoc nicknamed-package new-local-nicknames :test #'eq))
            (let ((old-locally-nicknamed-by (low:locally-nicknamed-by
                                             client nicknamed-package)))
              (setf (low:locally-nicknamed-by client nicknamed-package)
                    (remove package old-locally-nicknamed-by
                            :test #'eq :count 1))))
          t))))

(defmethod delete-package :after ((client local-nicknames-mixin) (package t))
  ;; Remove nicknames so that PACKAGE is removed from locally
  ;; nicknamed-by lists of other packages.
  (loop for (nickname) in (low:local-nicknames client package)
        do (remove-local-nickname client package nickname))
  ;; Remove all local nicknames that other packages may have defined
  ;; for PACKAGE.
  (loop for naming-package in (low:locally-nicknamed-by client package)
        do (loop for (nickname . named-package) in (low:local-nicknames
                                                    client naming-package)
                 when (eq named-package package)
                   do (remove-local-nickname client naming-package nickname))))
