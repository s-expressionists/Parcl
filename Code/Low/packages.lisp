(cl:in-package #:common-lisp-user)

(defpackage #:parcl-low
  (:use #:common-lisp)
  (:shadow . #1=(#:package
                 #:make-symbol
                 #:make-package
                 #:find-symbol
                 #:import
                 #:shadowing-import
                 #:use-package
                 #:unuse-package
                 #:export
                 #:unexport
                 #:shadow
                 #:intern
                 #:unintern
                 #:symbol-name
                 #:symbol-package))
  (:export #:name-to-entry
           #:remove-entry
           #:name
           #:nicknames
           #:shadowing-symbols
           #:use-list
           #:used-by-list
           #:make-table
           #:find-present-symbol
           #:ensure-present-symbol
           #:remove-present-symbol
           #:map-symbols
           #:map-external-symbols
           #:symbol-names-equal
           #:use-packages
           #:local-nicknames
           #:locally-nicknamed-by
           #:add-local-nickname
           #:remove-local-nickname
           . #1#))
