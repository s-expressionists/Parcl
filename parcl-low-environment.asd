(defsystem "parcl-low-environment"
  :description "Package system which stores package contents an environment object."
  :long-description "This system defines a package system that uses a package class
with no slots in it.  The package contents is instead contained in an
environment object."
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("parcl-core")
  :components ((:module     "low-environment"
                :pathname   "code/low/environment"
                :serial     t
                :components ((:file "packages")
                             (:file "client")
                             (:file "package")
                             #++ (:file "methods")))))
