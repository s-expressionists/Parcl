(defsystem "parcl-intrinsic"
  :description "Portable Package System, intrinsic variant"
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "../data/version-string.sexp")
  :depends-on  ("parcl-packages-intrinsic"
                "parcl-common"))
