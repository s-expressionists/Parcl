(cl:in-package #:parcl-low)

;;;; Package as symbol container

;;; This function is used to implement the standard function
;;; PACKAGE-SHADOWING-SYMBOLS.  Contrary to the Common Lisp standard
;;; function, the PACKAGE argument of this function must be a package
;;; object, whereas the standard function takes a package designator.
;;; The return value is a list of symbols that have been defined as
;;; shadowing symbols of PACKAGE.  This list is not freshly allocated,
;;; so if client code wants a fresh list, it must copy what this
;;; function returns.
#++ (defgeneric shadowing-symbols (client package))

;;; This function is used to implement the standard functions SHADOW
;;; and SHADOWING-IMPORT.  The PACKAGE argument of this function must
;;; be a package object.  NEW-SYMBOLS becomes the new list of
;;; shadowing symbols of PACKAGE.  The return value of this function
;;; is NEW-SYMBOLS as required by the Common Lisp standard.
#++ (defgeneric (setf shadowing-symbols) (new-symbols client package))

(defgeneric map-external-symbols (client package function))

(defgeneric map-symbols (client package function))

;;; Given a string, if a symbol with that name is present in PACKAGE,
;;; then return two values, the symbol and its status.  The status can
;;; be either :INTERNAL or :EXTERNAL. If there is no present symbol
;;; with that name in PACKAGE, then return NIL and NIL.
(defgeneric find-present-symbol (client package name))

;;; TODO: should probably set home package?
(defgeneric ensure-present-symbol (client package symbol &optional status))

;;; TODO: proper description | Remove from entries and unset home package
(defgeneric remove-present-symbol (client package symbol))
