(cl:defpackage #:parcl.middle
  (:use
   #:cl)

  (:local-nicknames
   (#:low #:parcl-low))

  ;; Package-package relation functions
  (:shadow
   . #1= (#:use-packages
          #:unuse-package))
  (:export
   #:add-local-nickname
   #:remove-local-nickname
   . #1#)

  ;; Package-symbol relation functions
  (:shadow
   . #2=(#:find-symbol
         #:intern
         #:unintern
         #:export
         #:unexport
         #:import
         #:shadowing-import
         #:shadow))
  (:export
   #:shadowing-symbols
   . #2#)

  ;; Environment functions
  (:shadow
   . #3=(#:make-package
         #:delete-package
         #:rename-package))
  (:export
   #:find-package-using-package
   . #3#))
