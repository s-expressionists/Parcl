;;; This package definition shadows some Common Lisp symbols in order
;;; to provide replacements of the same (symbol-)name for the
;;; designated definitions.
(cl:defpackage #:parcl
  (:use
   #:common-lisp)

  ;; Conditions
  (:shadow
   . #1=(#:package-error
         #:package-error-package))      ; reader
  (:export
   #:package-system-condition

   #:package-name-occupied-condition
   #:new-name                           ; reader
   #:existing-package                   ; reader

   #:package-name-occupied-error

   #:new-name-occupied-error

   #:package-does-not-exist-error

   #:package-variance-error
   #:aspect                             ; reader
   #:event                              ; reader
   #:value                              ; reader

   #:package-has-been-deleted-error

   ;; Conditions related to package-package relations
   #:package-in-use-error
   #:used-by                            ; reader

   #:nickname-refers-to-different-package-error
   #:nickname                           ; reader
   #:nicknamed-package                  ; reader

   ;; Conditions related to package-symbol relations
   #:symbol-conflicts-error
   #:conflicts                          ; reader
   #:package-labels                     ; reader

   #:symbol-is-not-accessible-error
   #:inaccessible-symbol                ; reader

   #:unexport-forbidden-for-system-package-error
   #:symbol-to-unexport                 ; reader
   . #1#)

  ;; Variables
  (:shadow
   . #2=(#:*package*

         ;; Macros
         #:defpackage
         #:in-package
         #:with-package-iterator
         #:do-symbols
         #:do-external-symbols
         #:do-all-symbols))
  (:export . #2#)

  ;; Symbol functions
  (:shadow
   . #3=(#:symbolp
         #:keywordp
         #:symbol-name
         #:symbol-package
         #:make-symbol))
  (:export . #3#)

  ;; Package functions
  (:shadow
   . #4=(#:packagep
         #:package-name
         #:package-nicknames
         #:package-shadowing-symbols
         #:package-use-list
         #:package-used-by-list))
  (:export
   ;; Package-local nicknames extension
   #:package-local-nicknames
   #:package-locally-nicknamed-by-list
   . #4#)

  ;; Package-package relation functions
  (:shadow
   . #5=(#:unuse-package
         #:use-package))
  (:export
   ;; Package-local nicknames extension
   #:add-package-local-nickname
   #:remove-package-local-nickname
   . #5#)

  ;; Package-symbol relation functions
  (:shadow
   . #6=(#:find-symbol
         #:import
         #:intern
         #:unintern
         #:export
         #:unexport
         #:shadow
         #:shadowing-import))
  (:export . #6#)

  ;; Environment functions
  (:shadow
   . #7=(#:list-all-packages
         #:find-package
         #:make-package
         #:delete-package
         #:rename-package
         #:find-all-symbols))
  (:export . #7#)

  ;; Additional variable
  (:export
   #:*client*))
