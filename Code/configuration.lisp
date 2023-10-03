(cl:in-package #:parcl)

;;;; This file contains definitions of generic functions that are
;;;; called by various parts of Parcl.  Client code must supply a
;;;; method on each one of these functions, specialized to the
;;;; paticular client object it uses.

;;; This function creates a symbol.  NAME is a string to be used as
;;; the name of the symbol.  PACKAGE is a package object or NIL.  If
;;; PACKAGE is NIL, then an uninterned symbol is created.
(defgeneric make-symbol (client name package))

;;; Given a symbol, this function returns the name of that symbol.
(defgeneric symbol-name (client symbol))

;;; Given a symbol, this function returns the package of that symbol.
;;; If the symbol is uninterned, then NIL is returned.
(defgeneric symbol-package (client symbol))

;;; Given a symbol and a package, this function sets the package of
;;; that symbol.  Parcl code will call this function only when the
;;; package of the symbol is NIL.
(defgeneric (setf symbol-package) (new-package client symbol))

;;; This function returns a symbol table, which is an object that can
;;; map client strings to client symbols.
(defgeneric make-symbol-table (client))

;;; This function takes a string and a symbol table and return two
;;; values.  the first value is a symbol in the table, or NIL if there
;;; is no symbol in the table with the name corresponding to the
;;; string.  The second value is true if there is a symbol with the
;;; name corresponding to the string in the table and NIL otherwise.
(defgeneric name-to-symbol (client name symbol-table))

;;; This function takes a symbol, a symbol name, and a symbol table,
;;; and it enters the symbol in the table associated with the name.
(defgeneric (setf name-to-symbol) (new-symbol client name symbol-table))
