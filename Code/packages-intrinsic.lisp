(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:local-nicknames (#:ico #:iconoclast)
                    (#:bld #:iconoclast-builder)
                    (#:ses #:s-expression-syntax))
  (:export . #.parcl-asdf:*string-designators*))
