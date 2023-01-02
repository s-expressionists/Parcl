(cl:in-package #:asdf-user)

;;;; This system defines a package system that uses a package object
;;;; with slots that hold all the information related to a package,

(defsystem #:parcl-class
  :serial t
  :components
  ((:file "package-defclass")))
