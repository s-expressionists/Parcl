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
