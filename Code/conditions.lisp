(in-package #:parcl)

(define-condition not-a-package-designator (type-error)
  ()
  (:report (lambda (condition stream)
             (format stream
                     "A package designator was required,~@
                      but the following was given:~@
                      ~s"
                     (type-error-datum condition))))
  (:default-initargs :expected-type '(or package character string symbol)))

(define-condition nicknames-must-be-proper-list (type-error)
  ()
  (:default-initargs :expected-type 'list)
  (:report (lambda (condition stream)
             (format stream
                     "The list of nicknames must be a proper list,~@
                      but the following was found instead:~@
                      ~s"
                     (type-error-datum condition)))))

(define-condition use-list-must-be-proper-list (type-error)
  ()
  (:default-initargs :expected-type 'list)
  (:report (lambda (condition stream)
             (format stream
                     "The list of used packages must be a proper list,~@
                      but the following was found instead:~@
                      ~s"
                     (type-error-datum condition)))))

(define-condition package-error (error)
  ((%package :initarg :package :reader package-error-package)))

(define-condition symbol-conflict (package-error)
  ((%conflicting-symbols
      :initarg :conflicting-symbols
      :reader conflicting-symbols)))

(define-condition symbol-is-not-accessible (package-error)
  ((%symbol :initarg :symbol :reader inaccessible-symbol)))

;;; This condition is signaled by UNUSE-PACKAGE when the package is
;;; not used, so that it can't be unused.
(define-condition package-is-not-used (package-error)
  ((%package-to-unuse
    :initarg :package-to-unuse
    :reader package-to-unuse))
  (:report (lambda (condition stream)
             (format stream
                     "A package to be unused must be a used package,~@
                      but the package:~@
                      ~s~@
                      is not used by the package:~@
                      ~s"
                     (package-to-unuse condition)
                     (package-error-package condition)))))
