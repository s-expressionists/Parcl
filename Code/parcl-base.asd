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
    #:make-symbol-table
    #:name-to-symbol
    #:nicknames
    #:shadowing-symbols
    #:use-packages
    #:use-list
    #:used-by-list
    #:external-symbols
    #:internal-symbols
    #:find-external-symbol
    #:add-external-symbol
    #:remove-external-symbol
    #:find-internal-symbol
    #:add-internal-symbol
    #:remove-internal-symbol
    #:find-shadowing-symbol
    #:add-shadowing-symbol
    #:remove-shadowing-symbol))

