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

;;; This function returns a table, which is an object that can map
;;; client strings to client entries.
(defgeneric make-table (client))

;;; This function takes a string and a table and returns two values.
;;; the first value is an entry in the table, or NIL if there is no
;;; entry in the table with the name corresponding to the string.  The
;;; second value is true if there is an entry with the name
;;; corresponding to the string in the table and NIL otherwise.
(defgeneric name-to-entry (client name table))

;;; This function takes a entry, a client string, and a table, and it
;;; adds the entry in the table associated with the string.
(defgeneric (setf name-to-entry) (new-entry client name table))
