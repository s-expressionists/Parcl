(cl:in-package #:common-lisp-user)

(defpackage parcl
  (:nicknames #:parcl-extrinsic)
  (:use #:common-lisp)
  (:shadow . #.parcl-asdf:*string-designators*)
  (:export . #.(append parcl-asdf:*string-designators*
                       parcl-asdf:*exports*)))
