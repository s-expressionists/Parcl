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
;;; the name of an existing package.
(defgeneric (setf name) (new-name client package))
