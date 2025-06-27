(defsystem "parcl-low"
  :description "Protocols and shared code for package system implementations."
  :serial t
  :components ((:file "packages")
               (:file "accessors")
               (:file "configuration")
               (:file "generic-functions")
               (:file "package-class")
               (:file "find-symbol")
               (:file "import")
               (:file "shadowing-import")
               (:file "use-packages")
               (:file "unuse-package")
               (:file "export")
               (:file "unexport")
               (:file "unintern")
               (:file "add-local-nickname")
               (:file "remove-local-nickname")
               (:file "condition-types")))
