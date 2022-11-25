(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:export . #.parcl-asdf:*string-designators*))
