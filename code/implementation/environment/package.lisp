(cl:defpackage #:parcl.implementation.environment
  (:use
   #:common-lisp)

  (:shadow
   #:package)

  (:local-nicknames
   (#:low #:parcl.low)
   (#:env #:computation.environment))

  (:export
   #:client))
