(cl:defpackage #:parcl-low-environment
  (:use
   #:common-lisp)

  (:shadow
   #:package)

  (:local-nicknames
   (#:low #:parcl-low)
   (#:env #:computation.environment))

  (:export
   #:client))
