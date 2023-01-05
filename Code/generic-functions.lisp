(cl:in-package #:parcl)

;;; This function can be used to implement the standard function
;;; FIND-SYMBOL.
(defgeneric find-symbol (client package name))
