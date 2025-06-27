(defsystem "parcl-low-class"
  :description "Package system which stores package contents in object slots"
  :long-description "This system defines a package system that uses a package object
with slots that holds all the information related to a package,"
  :version (:read-file-form "../../../data/version-string.sexp")
  :serial t
  :components ((:file "packages")
               (:file "client")
               (:file "package-defclass")
               (:file "methods")
               (:file "map-symbols")
               (:file "map-external-symbols")))
