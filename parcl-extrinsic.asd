(defsystem "parcl-extrinsic"
  :description "Portable Package System, extrinsic system"
  :license "BSD" ; see LICENSE file
  :author ("Robert Strandh"
           "Jan Moringen")
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("parcl-extrinsic/packages"
               "parcl-core")
  :in-order-to ((test-op (test-op "parcl-core"))))

;;; This system provides the extrinsic variant of the package!
;;; definitions that the rest of the code will use.
(defsystem "parcl-extrinsic/packages"
  :description "Internal helper system for extrinsic variant"
  :components ((:file "packages-extrinsic"
                :pathname "code/packages-extrinsic")))

(defsystem "parcl-extrinsic/ansi-test"
  :depends-on ("ansi-test-harness"

               "parcl-extrinsic"
               "parcl-core/test")

  :components ((:module     "test"
                :pathname   "test/ansi-test/"
                :components ((:file        "package")
                             (:static-file "expected-failures.sexp"))))

  :perform    (test-op (operation component)
                (uiop:symbol-call '#:parcl.ansi-test '#:test)))
