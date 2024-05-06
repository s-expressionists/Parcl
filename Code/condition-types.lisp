(cl:in-package #:parcl)

(define-condition symbol-name-must-be-string (type-error)
  ()
  (:report (lambda (condition stream)
             (format stream
                     "Symbol name must be a string, but the~@
                      following was given instead:~@
                      ~s"
                     (type-error-datum condition))))
  (:default-initargs :expected-type 'string))
