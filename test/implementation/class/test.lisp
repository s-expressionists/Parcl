(cl:defpackage #:parcl.implementation.class.test
  (:use
   #:cl)

  (:export
   #:run-tests))

(cl:in-package #:parcl.implementation.class.test)

(fiveam:def-suite* :parcl.implementation.class)

(defun run-tests ()
  (fiveam:run! :parcl.implementation.class))

(defclass class-client (parcl.implementation.class:client-with-local-nicknames
                        parcl.test::mock-symbol-mixin
                        parcl.test::mock-environment-mixin)
  ())

(defun make-client ()
  (make-instance 'class-client))

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
