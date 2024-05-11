(cl:defpackage #:parcl-asdf
  (:use #:common-lisp))

(cl:in-package #:parcl-asdf)

(asdf:defsystem #:parcl-base
  :serial t
  :description "Portable Package System, base system")
