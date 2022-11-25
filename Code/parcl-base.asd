(cl:defpackage #:parcl-asdf
  (:use #:common-lisp)
  (:export #:*string-designators*))

(cl:in-package #:parcl-asdf)

(asdf:defsystem #:parcl-base
  :serial t
  :description "Portable Package System, base system"
  :depends-on (#:s-expression-syntax))

(defparameter *string-designators*
  '(#:home-package
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
