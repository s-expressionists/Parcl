(defsystem "parcl-common"
  :description "Code that can be shared between different package system implementations"
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "../data/version-string.sexp")
  :depends-on ("ecclesia")
  :serial t
  :components ((:file "variables")
               (:file "utilities")
               (:file "package-name")
               (:file "package-nicknames")
               (:file "package-shadowing-symbols")
               (:file "package-use-list")
               (:file "package-used-by-list")
               (:file "intern")
               (:file "find-symbol")
               (:file "import")
               (:file "shadowing-import")
               (:file "use-package")
               (:file "unuse-package")
               (:file "export")
               (:file "unexport")
               (:file "shadow")
               (:file "add-package-local-nickname")
               (:file "remove-package-local-nickname")
               (:file "make-package")
               (:file "condition-types")))
