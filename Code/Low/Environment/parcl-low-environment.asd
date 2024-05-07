(cl:in-package #:asdf-user)

;;;; This system defines a package system that uses a package class
;;;; with no slots in it.  The package contents is instead contained
;;;; in an environment object.

(defsystem #:parcl-low-environment
  :serial t
  :components
  ((:file "packages")
   (:file "client")
   (:file "package-defclass")
   (:file "methods")))
