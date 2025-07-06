(cl:defpackage #:parcl-low
  (:use
   #:common-lisp)

  ;; Symbol functions
  (:shadow
   . #1=(#:symbolp
         #:symbol-name    ; also `setf'
         #:symbol-package ; also `setf'
         #:make-symbol))
  (:export
   . #1#)

  ;; Package functions
  (:shadow
   . #2=(#:packagep))
  (:export
   #:name                 ; also `setf'
   #:nicknames            ; also `setf'
   #:use-list             ; also `setf'
   #:used-by-list         ; also `setf'
   #:local-nicknames      ; also `setf'
   #:locally-nicknamed-by ; also `setf'
   #:make-package-object
   . #2#)

  ;; Package-symbol relation functions
  (:export
   #:map-symbol-entries
   #:symbol-entries
   #:symbol-entry
   #:set-symbol-entries)

  ;; Environment functions
  (:shadow
   . #3=(#:find-package)) ; also `setf'
  (:export
   ; TODO: #:list-all-packages
   . #3#))
