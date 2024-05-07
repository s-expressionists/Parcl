(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:nicknames #:parcl-intrinsic)
  (:use #:common-lisp)
  (:export . #.(append parcl-asdf:*string-designators*
                       parcl-asdf:*exports*)))

