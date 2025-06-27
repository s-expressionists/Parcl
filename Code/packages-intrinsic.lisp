(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:export #:*client*
           #:add-package-local-nickname
           #:remove-package-local-nickname
           #:store-package))
