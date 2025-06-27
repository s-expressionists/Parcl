(defsystem "parcl-intrinsic"
  :description "Portable Package System, intrinsic variant"
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "data/version-string.sexp")
  :depends-on  ("parcl-intrinsic/packages"
                "parcl-core"))

;;; This system provides the intrinsic variant of the package!
;;; definitions that the rest of the code will use.
(defsystem "parcl-intrinsic/packages"
  :description "Internal helper system for intrinsic variant"
  :components ((:file "packages-intrinsic"
                :pathname "code/packages-intrinsic")))
