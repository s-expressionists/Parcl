(asdf:defsystem #:parcl-extrinsic
  :serial t
  :description "Portable Package System, extrinsic system"
  :depends-on (#:parcl-low
               #:parcl-packages-extrinsic
               #:parcl-common))
