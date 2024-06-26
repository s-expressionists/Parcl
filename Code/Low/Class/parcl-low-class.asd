(cl:in-package #:asdf-user)

;;;; This system defines a package system that uses a package object
;;;; with slots that hold all the information related to a package,

(defsystem #:parcl-low-class
  :serial t
  :components
  ((:file "packages")
   (:file "client")
   (:file "package-defclass")
   (:file "methods")
   (:file "map-symbols")
   (:file "map-external-symbols")))
