(cl:defpackage #:parcl
  (:use
   #:common-lisp)
  ;; Shadow Common Lisp symbols in order to provide replacements of
  ;; the same (symbol-)name for the designated definitions.
  (:shadow
   . #1=(;; Variables
         #:*package*
         ;; Conditions
         #:package-error
         #:package-error-package
         ;; Symbol functions
         #:symbolp
         #:symbol-name
         #:symbol-package
         #:make-symbol
         ;; Package functions
         #:packagep
         #:package-name
         #:package-nicknames
         #:package-shadowing-symbols
         #:package-use-list
         #:package-used-by-list
         #:make-package ; TODO: diagram has this as environment function
         ;; Package-package relation functions
         #:unuse-package
         #:use-package
         ;; Package-symbol relation functions
         #:import
         #:intern
         #:unintern
         #:export
         #:unexport
         #:shadow
         #:shadowing-import
         ;; ?
         #:find-symbol
         #:find-all-symbols ; TODO: not implemented
         ;; Environment functions
         #:list-all-packages
         #:find-package
         #:delete-package
         #:rename-package
         ;; Macros
         #:defpackage
         #:with-package-iterator
         #:do-symbols
         #:do-external-symbols))
  ;; Export names of the replacements for the shadowed Common Lisp
  ;; variables, condition types and operators.
  (:export . #1#)
  ;; Export names of operators for the package-local nicknames
  ;; extension.
  (:export
   #:package-local-nicknames
   #:package-locally-nicknamed-by ; TODO: -list ?
   #:add-package-local-nickname
   #:remove-package-local-nickname)
  ;; Export the names of additional variables and functions that
  ;; clients can use to customize the package system.
  (:export
   #:*client*))
