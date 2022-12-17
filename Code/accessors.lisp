(cl:in-package #:parcl)

;;;; This file contains essential accessors for package objects.  They
;;;; are deliberately distinct from any standard Common Lisp function,
;;;; because we might want different implementations of these
;;;; accessors in different contexts.

;;; This function is used to implement the standard function
;;; PACKAGE-NAME.  Contrary to the Common Lisp standard function, the
;;; PACKAGE argument of this function must be a package object,
;;; whereas the standard function takes a package designator.
(defgeneric name (client package))

;;; This function is used to implement the standard function
;;; RENAME-PACKAGE.  The PACKAGE argument of this function must be a
;;; package object.  This function does not check whether NEW-NAME is
;;; the name or the nickname of an existing package.  The return value
;;; of this function is NEW-NAME as required by the Common Lisp
;;; standard.
(defgeneric (setf name) (new-name client package))

;;; This function is used to implement the standard function
;;; PACKAGE-NICKNAMES.  Contrary to the Common Lisp standard function,
;;; the PACKAGE argument of this function must be a package object,
;;; whereas the standard function takes a package designator.  The
;;; return value is a list of nicknames of PACKAGE.  This list is not
;;; freshly allocated, so if client code wants a fresh list, it must
;;; copy what this function returns.
(defgeneric nicknames (client package))

;;; This function is used to implement the standard function
;;; RENAME-PACKAGE.  The PACKAGE argument of this function must be a
;;; package object.  NEW-NICKNAMES is a list of strings that become
;;; the new list of nicknames of PACKAGE.  This function does not
;;; check whether NEW-NICKNAMES contains a string that is already the
;;; name or the nickname of any existing package.  The return value of
;;; this function is NEW-NICKNAMES as required by the Common Lisp
;;; standard.
(defgeneric (setf nicknames) (new-nicknames client package))

;;; This function is used to implement the standard function
;;; PACKAGE-SHADOWING-SYMBOLS.  Contrary to the Common Lisp standard
;;; function, the PACKAGE argument of this function must be a package
;;; object, whereas the standard function takes a package designator.
;;; The return value is a list of symbols that have been defined as
;;; shadowing symbols of PACKAGE.  This list is not freshly allocated,
;;; so if client code wants a fresh list, it must copy what this
;;; function returns.
(defgeneric shadowing-symbols (client package))

;;; This function is used to implement the standard functions SHADOW
;;; and SHADOWING-IMPORT.  The PACKAGE argument of this function must
;;; be a package object.  NEW-SYMBOLS becomes the new list of
;;; shadowing symbols of PACKAGE.  The return value of this function
;;; is NEW-SYMBOLS as required by the Common Lisp standard.
(defgeneric (setf shadowing-symbols) (new-symbols client package))
