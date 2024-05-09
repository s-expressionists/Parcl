(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:use #:common-lisp)
  (:export . #.(append parcl-asdf:*string-designators*
                       parcl-asdf:*exports*)))

