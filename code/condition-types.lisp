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

(define-condition symbols-must-be-designator-for-list-of-symbols (error)
  ((%symbols :initarg :symbols :reader symbols))
  (:report (lambda (condition stream)
             (format stream
                     "Argument must be a designator for a list of symbols,~@
                      but the following was found instead:~@
                      ~s"
                     (symbols condition)))))
