(cl:in-package #:asdf-user)

(defsystem "parcl-macros"
  :serial t
  :components
  ((:file "do-symbols")
   (:file "do-external-symbols")
   (:file "defpackage")))
