(asdf:defsystem #:parcl-common
  :depends-on ("ecclesia")
  :serial t
  :components
  ((:file "variables")
   (:file "utilities")
   (:file "find-symbol")
   (:file "import")
   (:file "use-package")
   (:file "condition-types")))
