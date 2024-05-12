(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:export #:add-package-local-nickname
           #:remove-package-local-nickname
           #:store-package))
