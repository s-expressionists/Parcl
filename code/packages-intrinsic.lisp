(cl:defpackage #:parcl
  (:use
   #:common-lisp)

  (:local-nicknames
   (#:a #:alexandria))

  ;; Export names of operators for the package-local nicknames
  ;; extension.
  (:export
   #:package-local-nicknames
   #:package-locally-nicknamed-by-list
   #:add-package-local-nickname
   #:remove-package-local-nickname)

  ;; Export the names of additional variables and functions that
  ;; clients can use to customize the package system.
  (:export
   #:*client*))
