(cl:defpackage #:parcl.middle
  (:use
   #:cl)

  (:local-nicknames
   (#:low #:parcl.low))

  ;; Symbol functions
  (:shadow
   . #1=(#:keywordp))
  (:export
   . #1#)

  ;; Package-package relation functions
  (:shadow
   . #2=(#:use-packages
         #:unuse-package))
  (:export
   #:add-local-nickname
   #:remove-local-nickname
   . #2#)

  ;; Package-symbol relation functions
  (:shadow
   . #3=(#:find-symbol
         #:intern
         #:unintern
         #:export
         #:unexport
         #:import
         #:shadowing-import
         #:shadow))
  (:export
   #:shadowing-symbols
   . #3#)

  ;; Environment functions
  (:shadow
   . #4=(#:make-package
         #:delete-package
         #:rename-package))
  (:export
   #:packages
   #:find-package-using-package
   #:find-symbols
   . #4#)

  ;; Package updating functions
  (:export
   #:ensure-package
   #:ensure-package-using-package
   #:note-variance
   #:update-package)

  ;; Mixin classes
  (:export
   #:local-nicknames-mixin))
