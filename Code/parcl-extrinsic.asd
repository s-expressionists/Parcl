(defsystem "parcl-extrinsic"
  :description "Portable Package System, extrinsic system"
  :version (:read-file-form "../data/version-string.sexp")
  :depends-on  ("parcl-common"
                "parcl-low"
                "parcl-packages-extrinsic"))
