(cl:in-package #:asdf-user)

(defsystem "parcl-macros"
  :depends-on (#:iconoclast
               #:iconoclast-builder)
  :serial t
  :components
  ((:file "do-symbols")
   (:file "do-external-symbols")
   (:file "defpackage")))
