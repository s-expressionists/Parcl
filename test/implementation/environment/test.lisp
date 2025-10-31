(cl:defpackage #:parcl.implementation.environment.test
  (:use
   #:cl)

  (:export
   #:run-tests))

(cl:in-package #:parcl.implementation.environment.test)

(fiveam:def-suite* :parcl.implementation.environment)

(defun run-tests ()
  (fiveam:run! :parcl.implementation.environment))

;;;

(defvar **global-environment**
  (let ((environment (make-instance 'computation.environment:global-environment)))
    (setf (computation.environment:lookup :package 'computation.environment:namespace environment)
          (make-instance 'computation.environment::equal-namespace)
          (computation.environment:lookup :package-state 'computation.environment:namespace environment)
          (make-instance 'computation.environment::eq-namespace))
    environment))

(defun make-environment ()
  (make-instance 'computation.environment::lexical-environment
                 :parent **global-environment**))

;;;

(defclass environment-client (parcl.implementation.environment:client
                              parcl.middle:local-nicknames-mixin
                              parcl.test::mock-symbol-mixin)
  ())

(defmethod parcl.test::reset ((client environment-client))
  (reinitialize-instance client :environment (make-environment)))

(defun make-client ()
  (make-instance 'environment-client :environment (make-environment)))

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
