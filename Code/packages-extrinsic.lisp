(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:shadow
   . #1=(#:*package*
         #:find-package
         #:package-name
         #:package-nicknames
         #:package-shadowing-symbols
         #:package-use-list
         #:package-used-by-list
         #:package-error
         #:package-error-package
         #:rename-package
         #:make-package
         #:import
         #:intern
         #:unintern
         #:find-symbol
         #:export
         #:unexport
         #:shadow
         #:shadowing-import
         #:unuse-package
         #:use-package
         #:defpackage
         #:with-package-iterator
         #:do-symbols
         #:do-external-symbols))
  (:export #:*client*
           .  #1#))
