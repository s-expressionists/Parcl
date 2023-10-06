(cl:defpackage #:parcl-asdf
  (:use #:common-lisp)
  (:export #:*string-designators*
           #:*exports*))

(cl:in-package #:parcl-asdf)

(asdf:defsystem #:parcl-base
  :depends-on (#:iconoclast-builder)
  :serial t
  :description "Portable Package System, base system")

(defparameter *string-designators*
  '(#:home-package
    #:symbol-name
    #:symbol-package
    #:find-package
    #:delete-package
    #:make-symbol
    #:package
    #:packagep
    #:*package*
    #:package-name
    #:package-nicknames
    #:package-shadowing-symbols
    #:package-use-list
    #:package-used-by-list
    #:package-error
    #:package-error-package
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
    #:defpackage
    #:with-package-iterator
    #:do-symbols
    #:do-external-symbols))

(defparameter *exports*
  '(#:name
    #:make-table
    #:name-to-entry
    #:nicknames
    #:shadowing-symbols
    #:use-packages
    #:use-list
    #:used-by-list
    #:find-present-symbol
    #:ensure-present-symbol
    #:ensure-exported-symbol))
