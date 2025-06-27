(defsystem "parcl-low-environment"
  :description "Package system which stores package contents an environment object."
  :long-description "This system defines a package system that uses a package class
with no slots in it.  The package contents is instead contained in an
environment object."
  :serial t
  :components ((:file "packages")
               (:file "client")
               (:file "package-defclass")
               (:file "methods")))
