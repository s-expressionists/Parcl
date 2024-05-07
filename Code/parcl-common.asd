(asdf:defsystem #:parcl-common
  :depends-on ("ecclesia")
  :serial t
  :components
  ((:file "variables")
   (:file "utilities")
   (:file "find-symbol")
   (:file "import")
   (:file "use-package")
   (:file "unuse-package")
   (:file "export")
   (:file "unexport")
   (:file "add-package-local-nickname")
   (:file "condition-types")))
