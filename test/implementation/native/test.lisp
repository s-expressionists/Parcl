(cl:defpackage #:parcl.implementation.native.test
  (:use
   #:cl)

  (:export
   #:run-tests))

(cl:in-package #:parcl.implementation.native.test)

(fiveam:def-suite* :parcl.implementation.native)

(defun run-tests ()
  (fiveam:run! :parcl.implementation.native))

(defclass native-test-client (parcl.implementation.native:client)
  ((%created-system-packages :accessor created-system-packages
                             :initform '())
   (%created-packages        :accessor created-packages
                             :initform '())))

(defmethod parcl.middle:make-package :around
    ((client native-test-client) (name t) (nicknames t) (used-packages t))
  ;; Allow `make-package' once for "COMMON-LISP" and "KEYWORD", then complain.
  (cond ((not (member name '("COMMON-LISP" "KEYWORD") :test #'string=))
         (let ((package (call-next-method)))
           (pushnew package (created-packages client))
           package))
        ((member name (created-system-packages client))
         (call-next-method))
        (t
         (push name (created-system-packages client))
         (find-package name))))

(defmethod parcl.test::reset ((client native-test-client))
  (handler-bind ((error #'continue))
    (mapc #'delete-package (created-packages client))))

(defun make-client ()
  (make-instance 'native-test-client))

(macrolet ((define-tests ()
             (let ((test-forms '()))
               (maphash
                (lambda (name body)
                  (let ((name (intern (symbol-name name))))
                    (push `(fiveam:test ,name
                             (let ((parcl.test::*client-maker* 'make-client))
                               ,@body))
                          test-forms)))
                parcl.test::*high-tests*)
               `(progn ,@test-forms))))
  (define-tests))
