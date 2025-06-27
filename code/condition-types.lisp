(cl:in-package #:parcl)

(define-condition package-system-condition (acclimation:condition)
  ())

(define-condition symbol-name-must-be-string (type-error
                                              package-system-condition)
  ()
  (:default-initargs :expected-type 'string))

(define-condition symbols-must-be-designator-for-list-of-symbols
    (error package-system-condition)
  ((%symbols :initarg :symbols :reader symbols)))

(define-condition package-error (error package-system-condition)
  ((%package :initarg #1=:package
             :reader  package-error-package))
  (:default-initargs
   #1# (error "Required argument ~s" #1#)))

(define-condition package-does-not-exist-error (package-error)
  ()
  (:report
   (lambda (condition stream)
     (format stream "~@<~S does designate a package.~@:>"
             (package-error-package condition)))))

(define-condition symbol-conflict (package-error)
  ((%conflicting-symbols :initarg :conflicting-symbols
                         :reader  conflicting-symbols)))

(defun symbol-conflict (package &rest conflicting-symbols)
  (error 'symbol-conflict :package             package
                          :conflicting-symbols conflicting-symbols))

(define-condition symbol-is-not-accessible (package-error)
  ((%symbol :initarg :symbol
            :reader  inaccessible-symbol)))

;;; This condition is signaled by UNUSE-PACKAGE when the package is
;;; not used, so that it can't be unused.
(define-condition package-is-not-used (package-error)
  ((%package-to-unuse :initarg :package-to-unuse
                      :reader  package-to-unuse)))

(define-condition nickname-refers-to-different-package (package-error)
  ((%nickname          :initarg :nickname
                       :reader  nickname)
   (%nicknamed-package :initarg :nicknamed-package
                       :reader  nicknamed-package)))
