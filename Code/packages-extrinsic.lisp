(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:shadow . #.parcl-asdf:*string-designators*)
  (:export . #.parcl-asdf:*string-designators*))
