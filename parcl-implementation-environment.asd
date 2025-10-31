(defsystem "parcl-implementation-environment"
  :description "Package system which stores package contents an environment object."
  :long-description "This system defines a package system that uses a package class
with no slots in it.  The package contents is instead contained in an
environment object."
  :license "BSD" ; see LICENSE file
  :author ("Robert Strandh"
           "Jan Moringen")
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("alexandria"

               "computation.environment"

               "parcl-core")
  :components ((:module     "implementation-environment"
                :pathname   "code/implementation/environment"
                :serial     t
                :components ((:file "package")
                             (:file "client")
                             (:file "methods"))))
  :in-order-to ((test-op (test-op "parcl-implementation-environment/test"))))

(defsystem "parcl-implementation-environment/test"
  :depends-on ("fiveam"

               "parcl-core/test" ; for `parcl.test::*high-tests*'

               "parcl-implementation-environment")
  :components  ((:module     "implementation-environment"
                 :pathname   "test/implementation/environment"
                 :components ((:file "test"))))
  :perform     (test-op (operation component)
                 (uiop:symbol-call '#:parcl.implementation.environment.test
                                   '#:run-tests)))
