(cl:in-package #:parcl)

;;; This function can be used to implement the standard function
;;; FIND-SYMBOL.
(defgeneric find-symbol (client package name))

;;; This function can be used to implement the standard function
;;; IMPORT.  If, as a result of a call to this function, SYMBOL is
;;; imported into PACKAGE, and SYMBOL has no home packge then client
;;; code is responsible for setting the home package of SYMBOL to
;;; PACKAGE.
(defgeneric import (client package symbol))

;;; This function can be used to implement the standard function
;;; USE-PACKAGE.
(defgeneric use-packages (client package packages-to-use))

;;; This function can be used to implement the standard function
;;; UNUSE-PACKAGE.  It differs from the standard function in that it
;;; takes a single package to unuse as opposed to a list of packages
;;; to unuse. Client code for the standard function must then call
;;; this function multiple times.
(defgeneric unuse-package (client package packages-to-unuse))

;;; This function can be used to implement the standard function EXPORT.
;;; It differs from the standard function in that it takes a single
;;; symbol as opposed to a list of symbols. Client code for the standard
;;; function must then call this function multiple times.
(defgeneric export (client package symbol))
