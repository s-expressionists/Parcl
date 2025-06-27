(cl:in-package #:parcl-low)

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

(define-condition nickname-refers-to-different-package (package-error)
  ((%nickname
    :initarg :nickname
    :reader nickname)
   (%nicknamed-package
    :initarg :nicknamed-package
    :reader nicknamed-package))
  (:report (lambda (condition stream)
             (format stream
                     "Attempt to add the package-local nickname:~@
                      ~s~@
                      to refer to the package:~@
                      ~s~@
                      in the package:~@
                      ~s,~@
                      but that nickname already refers to a different~@
                      package."
                     (nickname condition)
                     (nicknamed-package condition)
                     (package-error-package condition)))))
