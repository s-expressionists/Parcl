(cl:defpackage #:parcl-asdf
  (:use #:common-lisp)
  (:export #:*string-designators*))

(cl:in-package #:parcl-asdf)

(asdf:defsystem #:parcl-extrinsic
  :serial t
  :description "Portable Package System, extrinsic system"
  :depends-on (#:parcl-base)
  :components ((:file "packages-extrinsic")
               . #.*component-designators*))
