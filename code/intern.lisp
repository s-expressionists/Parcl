(cl:in-package #:parcl)

(defun intern (name &optional (package *package*))
  ;; TODO: check NAME
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (parcl.middle:intern client package name)))
