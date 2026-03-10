(cl:in-package #:parcl)

(define-condition macro-syntax-error (simple-error
                                      program-error
                                      package-system-condition)
  ((%expression :initarg #1=:expression
                :reader  expression))
  (:default-initargs
   #1# (a:required-argument #1#)))

;;; Conditions specific to `with-package-iterator'

(define-condition iterator-at-end-error (package-system-condition)
  ()
  (:documentation
   "This error is signaled if an iterator that has been established by
`with-package-itertor' is invoked after it has returned false as its
primary value."))
