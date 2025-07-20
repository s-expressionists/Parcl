(cl:defpackage #:parcl-low
  (:use
   #:common-lisp)

  ;; Symbol functions
  (:shadow
   . #1= (:symbolp
          #:symbol-name
         #:symbol-package
          #:make-symbol))
  (:export
   . #1#)

  ;; Package functions
  (:shadow
   . #2=(#:package
         #:packagep
         #:documentation))
  (:export
   #:name
   #:nicknames
   #:use-list
   #:used-by-list
   #:local-nicknames
   #:locally-nicknamed-by
   #:make-package-object
   . #2#)

  ;; Package-symbol relation functions
  (:shadow
   . #3=(#:find-symbol))
  (:export
   #:name-to-entry                      ; TODO: remove
   #:remove-entry
   #:make-table
   #:find-present-symbol
   #:ensure-present-symbol
   #:remove-present-symbol

   #:map-symbol-entries
   #:symbol-entries
   #:symbol-entry                       ; also `setf'
   #:set-symbol-entry
   . #3#)

  ;; Environment functions
  (:shadow
   . #4=(#:find-package))
  (:export
   #:packages
   . #4#))
