(cl:defpackage #:parcl.implementation.environment
  (:use
   #:common-lisp)

  (:local-nicknames
   (#:a   #:alexandria)
   (#:low #:parcl.low)
   (#:env #:computation.environment))

  (:shadow
   #:package)

  (:export
   #:client))
