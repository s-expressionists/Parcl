(asdf:defsystem #:parcl-common
  :serial t
  :components
  ((:file "variables")
   (:file "utilities")
   (:file "accessors")
   (:file "configuration")
   (:file "generic-functions")
   (:file "package-defclass")
   (:file "conditions")
   (:file "find-symbol-defmethod")
   (:file "import-defmethod")
   (:file "use-packages-defmethod")
   (:file "unuse-package-defmethod")
   (:file "export-defmethod")
   (:file "unexport-defmethod")
   (:file "add-package-local-nickname")
   (:file "remove-package-local-nickname")))
