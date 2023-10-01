(cl:in-package #:common-lisp-user)

(defpackage parcl-class
  (:use #:common-lisp)
  (:shadow #:package)
  (:export
     #:client
     #:name
     #:nicknames
     #:local-nicknames
     #:use-list
     #:used-by-list
     #:external-symbols
     #:internal-symbols
     #:shadowing-symbols))
