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
;;; name or the nickname of any existing package.  This function does
;;; not copy the NEW-NICKNAMES list, so client code should make sure
;;; this list is not used after being passed as an argument to this
;;; function.  The return value of this function is NEW-NICKNAMES as
;;; required by the Common Lisp standard.
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

;;; This function is used to implement the standard function
;;; PACKAGE-USE-LIST.  Contrary to the Common Lisp standard function,
;;; the PACKAGE argument of this function must be a package object,
;;; whereas the standard function takes a package designator.  The
;;; return value is a list of package objects.  This list is not
;;; freshly allocated, so if client code wants a fresh list, it must
;;; copy what this function returns.
(defgeneric use-list (client package))

;;; This function is used to implement the standard functions
;;; USE-PACKAGE and UNUSE-PACKAGE.  The PACKAGE argument of this
;;; function must be a package object.  NEW-PACKAGES is a list of
;;; package objects that become the new list of packages used by
;;; PACKAGE.  This function does not copy the NEW-PACKAGES list, so
;;; client code should make sure this list is not used after being
;;; passed as an argument to this function.  The return value of this
;;; function is NEW-PACKAGES as required by the Common Lisp standard.
(defgeneric (setf use-list) (new-packages client package))

;;; This function is used to implement the standard function
;;; PACKAGE-USED-BY-LIST.  Contrary to the Common Lisp standard
;;; function, the PACKAGE argument of this function must be a package
;;; object, whereas the standard function takes a package designator.
;;; The return value is a list of package objects.  This list is not
;;; freshly allocated, so if client code wants a fresh list, it must
;;; copy what this function returns.
(defgeneric used-by-list (client package))

;;; This function is used to implement the standard functions
;;; USE-PACKAGE and UNUSE-PACKAGE.  The PACKAGE argument of this
;;; function must be a package object.  NEW-PACKAGES is a list of
;;; package objects that become the new list of packages used by
;;; PACKAGE.  This function does not copy the NEW-PACKAGES list, so
;;; client code should make sure this list is not used after being
;;; passed as an argument to this function.  The return value of this
;;; function is NEW-PACKAGES as required by the Common Lisp standard.
(defgeneric (setf used-by-list) (new-packages client package))

;;; Return a list of all the external symbols of PACKAGE.  This list
;;; must not be mutated as it reveals the internal state of the
;;; package.  The list returned by this function can be used to
;;; implement iterators that traverse the external symbols.
(defgeneric external-symbols (client package))

;;; Return a list of all the internal symbols of PACKAGE.  This list
;;; must not be mutated as it reveals the internal state of the
;;; package.  The list returned by this function can be used to
;;; implement iterators that traverse the internal symbols.
(defgeneric internal-symbols (client package))

;;; Given a string, if an external symbol with that name exists in
;;; PACKAGE, then return two values, the symbol and T.  If there is no
;;; external symbol with that name in PACKAGE, then return NIL and
;;; NIL.  It is preferable to use this function over traversing the
;;; list returned by EXTERNAL-SYMBOLS, because it is typically faster.
(defgeneric find-external-symbol (client package))

;;; Given a symbol, add it as an external symbol to PACKAGE.  The
;;; symbol must not already be an external or an internal symbol of
;;; PACKAGE, but this situation is not tested for.  Also, if the
;;; package of SYMBOL is NIL, we do not modify it.
(defgeneric add-external-symbol (client package symbol))

;;; Given a symbol, remove it as an external symbol from PACKAGE.  The
;;; symbol must already be an external symbol of PACKAGE, but this
;;; situation is not tested for.
(defgeneric remove-external-symbol (client package symbol))

;;; Given a string, if an internal symbol with that name exists in
;;; PACKAGE, then return two values, the symbol and T.  If there is no
;;; internal symbol with that name in PACKAGE, then return NIL and
;;; NIL.  It is preferable to use this function over traversing the
;;; list returned by INTERNAL-SYMBOLS, because it is typically faster.
(defgeneric find-internal-symbol (client package))

;;; Given a symbol, add it as an internal symbol to PACKAGE.  The
;;; symbol must not already be an internal or an internal symbol of
;;; PACKAGE, but this situation is not tested for.  Also, if the
;;; package of SYMBOL is NIL, we do not modify it.
(defgeneric add-internal-symbol (client package symbol))

;;; Given a symbol, remove it as an internal symbol from PACKAGE.  The
;;; symbol must already be an internal symbol of PACKAGE, but this
;;; situation is not tested for.
(defgeneric remove-internal-symbol (client package symbol))

;;; Given a string, if a shadowing symbol with that name exists in
;;; PACKAGE, then return two values, the symbol and T.  If there is no
;;; shadowing symbol with that name in PACKAGE, then return NIL and
;;; NIL.  This function exists as a convenience, but it is implemented
;;; as a traversal of the list returned by SHADOWING-SYMBOLS.
(defgeneric find-shadowing-symbol (client package))

;;; Given a symbol, add it as a shadowing symbol to PACKAGE.  The
;;; symbol must not already be a shadowing or an internal symbol of
;;; PACKAGE, but this situation is not tested for.  Also, if the
;;; package of SYMBOL is NIL, we do not modify it.
(defgeneric add-shadowing-symbol (client package symbol))

;;; Given a symbol, remove it as a shadowing symbol from PACKAGE.  The
;;; symbol must already be a shadowing symbol of PACKAGE, but this
;;; situation is not tested for.
(defgeneric remove-shadowing-symbol (client package symbol))
