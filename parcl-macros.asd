(defsystem "parcl-macros"
  :description "Definitions of macros related to the package system."
  :license "BSD" ; see LICENSE file
  :author ("Robert Strandh"
           "Jan Moringen")
  :version (:read-file-form "data/version-string.sexp")
  :depends-on ("ecclesia"
               "iconoclast"
               "iconoclast-builder")
  :components ((:module     "macros"
                :pathname   "code/macros"
                :serial     t
                :components ((:file "condition-types")
                             (:file "utilities")
                             (:file "in-package")
                             (:file "defpackage")
                             (:file "with-package-iterator")
                             (:file "do-symbols-macros"))))
  :in-order-to ((test-op (test-op "parcl-macros/test"))))

(defsystem "parcl-macros/test"
  :depends-on ("fiveam"
               "parcl-macros")

  :components ((:module     "test"
                :pathname   "test/macros"
                :serial     t
                :components ((:file "package")
                             (:file "in-package")
                             (:file "defpackage")
                             (:file "with-package-iterator")
                             (:file "do-symbols-macros"))))
  :perform (test-op (operation component)
             (uiop:symbol-call '#:parcl.macros.test '#:run-tests)))
