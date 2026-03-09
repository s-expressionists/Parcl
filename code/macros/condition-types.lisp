(cl:in-package #:parcl)

(define-condition macro-syntax-error (simple-error program-error) ())
;;; Conditions specific to `with-package-iterator'

(define-condition iterator-at-end-error (package-system-condition)
  ()
  (:documentation
   "This error is signaled if an iterator that has been established by
`with-package-itertor' is invoked after it has returned false as its
primary value."))
