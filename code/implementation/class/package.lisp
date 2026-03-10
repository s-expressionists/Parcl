(cl:defpackage #:parcl.implementation.class
  (:use
   #:common-lisp)

  (:local-nicknames
   (#:a #:alexandria))

  (:shadow
   #:package
   #:documentation)

  ;; Client class
  (:export
   #:class-packages-mixin
   #:client
   #:client-with-local-nicknames)

  ;; Package classes
  (:export
   #:local-nicknames-mixin
   #:package
   #:package-with-local-nicknames)

  ;; Package object protocol
  (:export
   #:name
   #:nicknames
   #:local-nicknames
   #:locally-nicknames-by
   #:use-list
   #:used-by-list))
