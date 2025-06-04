(cl:in-package #:asdf-user)

(defsystem "parcl-macros"
  :depends-on (#:iconoclast
               #:iconoclast-builder)
  :serial t
  :components
  ((:file "with-package-iterator")
   (:file "do-symbols")
   (:file "do-external-symbols")
   #+(or)(:file "defpackage")))
