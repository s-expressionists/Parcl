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
