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
         ;; Functions
         #:find-package
         #:package-name
         #:package-nicknames
         #:package-shadowing-symbols
         #:package-use-list
         #:package-used-by-list
         #:rename-package
         #:make-package
         #:import
         #:intern
         #:unintern
         #:find-symbol
         #:export
         #:unexport
         #:shadow
         #:shadowing-import
         #:unuse-package
         #:use-package
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
   #:add-package-local-nickname
   #:remove-package-local-nickname)
  ;; Export the names of additional variables and functions that
  ;; clients can use to customize the package system.
  (:export
   #:*client*
   #:store-package))
