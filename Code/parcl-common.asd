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
   (:file "unuse-package-defmethod")
   (:file "export-defmethod")
   (:file "unexport-defmethod")
   (:file "add-package-local-nickname")
   (:file "remove-package-local-nickname")))
