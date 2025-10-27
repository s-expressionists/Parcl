(cl:in-package #:parcl)

(defun expand-in-package (package-name)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     ;; TODO: should this take into account local nicknames or generally `find-package-using-package'?
     (setf *package* (find-undeleted-package-or-error *client* ,package-name))))

(define-macro in-package (package-designator) node
  (let ((package-name (string<-designator-node
                       (architecture.builder-protocol:node-relation
                        **builder** '(:name . 1) node))))
    (expand-in-package package-name)))
