(defsystem "parcl-intrinsic"
  :description "Portable Package System, intrinsic variant"
  :version (:read-file-form "../data/version-string.sexp")
  :depends-on  ("parcl-packages-intrinsic"
                "parcl-common"))
