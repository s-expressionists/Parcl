(cl:in-package #:parcl)

(defmacro in-package (&whole form package-designator)
  (declare (ignore package-designator))
  (let* ((ast          (parse form :replace-operator 'cl:in-package))
         (package-name (ico:designated-string (ico:name-ast ast))))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       ;; TODO: should this take into account local nicknames or generally `find-package-using-package'?
       (setf *package* (find-undeleted-package-or-error *client* ,package-name)))))
