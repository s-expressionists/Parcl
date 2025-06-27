(defsystem "parcl-macros"
  :description "Definitions of macros related to the package system."
  :version (:read-file-form "../../data/version-string.sexp")
  :depends-on ("iconoclast"
               "iconoclast-builder")
  :serial t
  :components ((:file "with-package-iterator")
               (:file "do-symbols")
               (:file "do-external-symbols")
               #+(or)(:file "defpackage")))
