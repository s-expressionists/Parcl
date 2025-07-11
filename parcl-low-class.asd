(defsystem "parcl-low-class"
  :description "Package system which stores package contents in object slots"
  :long-description "This system defines a package system that uses a package object
with slots that holds all the information related to a package."
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("parcl-core")
  :components ((:module     "low-class"
                :pathname   "code/low/class"
                :serial     t
                :components ((:file "packages")
                             (:file "client")
                             (:file "package-defclass")
                             (:file "methods")
                             (:file "map-symbols")
                             (:file "map-external-symbols"))))
  :in-order-to ((test-op (test-op "parcl-low-class/test"))))

(defsystem "parcl-low-class/test"
  :depends-on  ("fiveam"
                "parcl-core/test")
  :components  ((:file     "test"
                :pathname "test/low/class/test"))
  :perform     (test-op (operation component)
                 (uiop:symbol-call '#:parcl-low-class.test '#:run-tests)))
