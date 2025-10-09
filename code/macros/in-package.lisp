(cl:in-package #:parcl)

(defun expand-in-package (package-name)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     ;; TODO: should this take into account local nicknames or generally `find-package-using-package'?
     (setf *package* (find-undeleted-package-or-error *client* ,package-name))))

(define-macro in-package (package-designator) ast
  (let ((package-name (ico:designated-string (ico:name-ast ast))))
    (expand-in-package package-name)))
