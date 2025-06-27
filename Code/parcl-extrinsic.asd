(defsystem "parcl-extrinsic"
  :description "Portable Package System, extrinsic system"
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :version (:read-file-form "../data/version-string.sexp")
  :depends-on  ("parcl-common"
                "parcl-low"
                "parcl-packages-extrinsic"))
