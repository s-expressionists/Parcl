(cl:defpackage #:parcl.low
  (:use
   #:common-lisp)

  ;; Symbol functions
  (:shadow
   . #1= (#:symbolp
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
  (:export
   #:map-symbol-entries
   #:symbol-entry ; also `setf'
   #:set-symbol-entry)

  ;; Environment functions
  (:shadow
   . #3=(#:find-package)) ; also `setf'
  (:export
   #:packages
   . #3#))
