(cl:in-package #:common-lisp-user)

(defpackage #:parcl-low
  (:use #:common-lisp)
  (:shadow . #1=(#:package
                 #:make-symbol
                 #:make-package
                 #:find-symbol
                 #:import
                 #:shadowing-import
                 #:use-package
                 #:unuse-package
                 #:export
                 #:unexport
                 #:shadow
                 #:intern
                 #:unintern
                 #:symbol-name
                 #:symbol-package))
  (:export . #1#))
