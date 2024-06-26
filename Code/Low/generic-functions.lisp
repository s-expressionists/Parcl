(cl:in-package #:parcl-low)

;;; This function can be used to implement the standard function
;;; MAKE-PACKAGE.  As opposed to the standard function, NAME must be a
;;; string.
(defgeneric make-package (client name))

;;; This function can be used to implement the standard function
;;; FIND-SYMBOL.  Just like the standard function, it returns two
;;; values.  The first value is either a symbol with the name NAME
;;; accessible in PACKAGE, or NIL if there is no such symbol.  The
;;; second value is either :INTERNAL, :EXTERNAL, :INHERITED, or NIL.
(defgeneric find-symbol (client package name))

;;; This function can be used to implement the standard function
;;; IMPORT.  If, as a result of a call to this function, SYMBOL is
;;; imported into PACKAGE, and SYMBOL has no home packge (as
;;; determined by a call to SYMBOL-PACKAGE) then this function calls
;;; (SETF SYMBOL-PACKAGE) with PACKAGE, CLIENT, and SYMBOL as
;;; arguments.
(defgeneric import (client package symbol))

(defgeneric shadowing-import (client package symbol))

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

;;; This function can be used to implement the standard function
;;; UNEXPORT.  It differs from the standard function in that it takes
;;; a single symbol as opposed to a list of symbols. Client code for
;;; the standard function must then call this function multiple times.
(defgeneric unexport (client package symbol))

;;; This function can be used to implement the standard function
;;; SHADOW.  It differs from the standard function in that it takes a
;;; single string as opposed to a list of string designators. Client
;;; code for the standard function must then call this function
;;; multiple times.  This function calls FIND-SYMBOL to determine
;;; whether a symbol with the name NAME is present (i.e., it is
;;; directly accessible) in PACKAGE.  If that is the case, then that
;;; existing symbol is added to the set of shadowing symbols of
;;; PACKAGE.  If no such symbol is present in PACKAGE, this function
;;; calls MAKE-SYMBOL, passing it CLIENT, NAME, and PACKAGE as
;;; arguments.  The resulting symbol is then added to PACKAGE as an
;;; internal symbol and as a shadowing symbol.
(defgeneric shadow (client package name))

;;; This function can be used to implement the standard function
;;; INTERN.  Client code is responsible for making SYMBOL external if
;;; PACKAGE is the KEYWORD package.
(defgeneric intern (client package name))

;;; This function can be used to implement the standard function
;;; UNINTERN.  If SYMBOL is present in PACKAGE it is removed so that
;;; it is no longer present.  It is also removed from the list of
;;; shadowing symbols of PACKAGE.  If PACKGE is the home package of
;;; SYMBOL, as determined by a call to SYMBOL-PACKAGE, then this
;;; function calls (SETF SYMBOL-PACKAGE) with NIL, CLIENT, and SYMBOL
;;; as arguments.
(defgeneric unintern (client package symbol))

;;; This function can be used to implement the semi-standard function
;;; ADD-PACKAGE-LOCAL-NICKNAME.  NICKNAME is a string that represents
;;; the local nickname to be used to refer to the nicknamed package.
;;; NICKNAMED-PACKAGE is a package object to be nicknamed.  PACKAGE is
;;; a package object to which the NICKNAME/NICKNAMED-PACKAGE pair is
;;; to be added.  If the NICKNAME/NICKNAMED-PACKAGE pair exists in
;;; PACKAGE already, then the call to this function has no effect.  If
;;; a NICKNAME/NICKNAMED-PACKAGE pair exists exists in PACKAGE already
;;; with the same nickname but a different nicknamed package, then an
;;; error is signaled.  Otherwise, the NICKNAME/NICKNAMED-PACKAGE pair
;;; is added to PACKAGE using the accessor LOCAL-NICKNAMES, and
;;; PACKAGE is added to NICKNAMED-PACKAGE using the accessor
;;; LOCALLY-NICKNAMED-BY.
(defgeneric add-local-nickname (client nickname nicknamed-package package))

;;; This function can be used to implement the semi-standard function
;;; REMOVE-PACKAGE-LOCAL-NICKNAME.  NICKNAME is a string that
;;; represents the local nickname to be removed from PACKAGE.  PACKAGE
;;; is a package object from which NICKNAME is to be removed.  If
;;; NICKNAME is the local nickname of any package in PACKAGE, then it
;;; is removed, and this function returns true.  If NICKNAME is not
;;; the local nickname of any package in PACKAGE, then this function
;;; has no effect, and returns NIL.
(defgeneric remove-local-nickname (client nickname package))

;;; This function is used by the macro DO-SYMBOLS to compute the
;;; expansion.
(defgeneric do-symbols-expander
    (client symbol-variable package-designator-form result-form body))

;;; This function is used by the macro DO-EXTERNAL-SYMBOLS to compute
;;; the expansion.
(defgeneric do-external-symbols-expander
    (client symbol-variable package-designator-form result-form body))
