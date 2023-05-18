(asdf:defsystem #:parcl-extrinsic
  :serial t
  :description "Portable Package System, extrinsic system"
  :depends-on (#:iconoclast-builder
               #:parcl-packages-extrinsic
               #:parcl-common))
