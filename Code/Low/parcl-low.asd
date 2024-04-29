(cl:in-package #:asdf-user)

(defsystem "parcl-low"
  :depends-on ()
  :serial t
  :components
  ((:file "packages")
   (:file "accessors")
   (:file "configuration")
   (:file "generic-functions")
   (:file "package-class")
   (:file "find-symbol")
   (:file "import")
   (:file "use-packages")
   (:file "unuse-package")))
