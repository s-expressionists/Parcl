(defsystem "parcl-implementation-class"
  :description "Package system which stores package contents in object slots"
  :long-description "This system defines a package system that uses a package object
with slots that holds all the information related to a package."
  :license "BSD" ; see LICENSE file
  :author ("Robert Strandh"
           "Jan Moringen")
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("alexandria"
               "parcl-core")
  :components ((:module     "implementation-class"
                :pathname   "code/implementation/class"
                :serial     t
                :components ((:file "package")
                             (:file "protocol")
                             (:file "client-classes")
                             (:file "package-classes")
                             (:file "methods"))))
  :in-order-to ((test-op (test-op "parcl-implementation-class/test"))))

(defsystem "parcl-implementation-class/test"
  :depends-on  ("fiveam"

                "parcl-core/test"   ; for `parcl.test::*high-tests*' and
                "parcl-macros/test" ; running macro tests with this backend

                "parcl-implementation-class")
  :components  ((:module     "implementation-class"
                 :pathname   "test/implementation/class/"
                 :components ((:file "test"))))
  :perform     (test-op (operation component)
                 (uiop:symbol-call '#:parcl.implementation.class.test '#:run-tests)))
