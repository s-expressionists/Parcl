(defsystem "parcl-macros"
  :description "Definitions of macros related to the package system."
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
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
                             (:file "do-symbols")
                             (:file "do-external-symbols")
                             (:file "do-all-symbols")))))
