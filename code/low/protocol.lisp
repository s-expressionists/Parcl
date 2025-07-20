(cl:in-package #:parcl-low)

;;;; Symbol functions

;;;; TODO: Old This file contains definitions of generic functions that are
;;;; called by various parts of Parcl.  Client code must supply a
;;;; method on each one of these functions, specialized to the
;;;; paticular client object it uses.

(defgeneric symbolp (client object)
    ;; Default behavior
  (:method ((client t) (object t))
    nil))

;;; Given a symbol, this function returns the name of that symbol.
(defgeneric symbol-name (client symbol))

;;; Given a symbol, this function returns the package of that symbol.
;;; If the symbol is uninterned, then NIL is returned.
(defgeneric symbol-package (client symbol))

;;; Given a symbol and a package, this function sets the package of
;;; that symbol.  Parcl code will call this function with a package
;;; object only when the symbol does not have a home package, and with
;;; NIL only when the symbol does have a home package.
(defgeneric (setf symbol-package) (new-package client symbol))

;;; This function creates a symbol.  NAME is a string to be used as
;;; the name of the symbol.  PACKAGE is a package object or NIL.  If
;;; PACKAGE is NIL, then an uninterned symbol is created.
(defgeneric make-symbol (client name package))

;;;; Package functions

;;;; TODO: Old This file contains essential accessors for package objects.  They
;;;; are deliberately distinct from any standard Common Lisp function,
;;;; because we might want different implementations of these
;;;; accessors in different contexts.

(defgeneric packagep (client object)
  ;; Default behavior
  (:method ((client t) (object t))
    nil))

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

;;; This function is used to implement the semi-standard function
;;; PACKAGE-LOCAL-NICKNAMES.  The PACKAGE argument of this function
;;; must be a package object.
(defgeneric local-nicknames (client package)
  (:method ((client t) (package t))
    (error "~@<Local nicknames are not supported by this package system.@~:>")))

(defgeneric (setf local-nicknames) (new-value client package))

;;; This function is used to implement the semi-standard function
;;; PACKAGE-LOCALLY-NICKNAMED-BY-LIST.  The PACKAGE argument of this
;;; function must be a package object.
(defgeneric locally-nicknamed-by (client package)
  (:method ((client t) (package t))
    (error "~@<Local nicknames are not supported by this package system.@~:>")))

(defgeneric (setf locally-nicknamed-by) (new-value client package))

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
;; TODO: why "list" in this name but not the other list-typed accessors?
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

;;; This function can be used to implement the standard function
;;; MAKE-PACKAGE.  As opposed to the standard function, NAME must be a
;;; string.
(defgeneric make-package-object (client name))

;;;; Package-symbol relation functions

;;; TODO: old The SYMBOL ENTRIES of a package is a list of CONS cells, each
;;; representing a present symbol and its status.  The CAR of such a
;;; CONS cell is the symbol itself, and the CDR is the status which is
;;; one of :INTERNAL, :INTERNAL-SHADOWING, :EXTERNAL, and
;;; :EXTERNAL-SHADOWING.

(defgeneric map-symbol-entries (client function package &optional status))

;;; This function returns the symbol entries of a package.
(defgeneric symbol-entries (client package &optional status))

;;; This function sets the symbol entries of a package.
#++ (defgeneric (setf symbol-entries) (symbol-entries client package))

(defgeneric symbol-entry (client name package))

(defgeneric set-symbol-entry
    (symbol export-status shadow-status client name package))

(defsetf symbol-entry (client name package) (symbol export-status shadow-status)
  `(set-symbol-entry
     ,symbol ,export-status ,shadow-status ,client ,name ,package))

;;;; Environment functions

(defgeneric packages (client))

(defgeneric find-package (client name))

(defgeneric (setf find-package) (new-value client name))

;;;; TODO

;;; This function is used by the macro DO-SYMBOLS to compute the
;;; expansion.
(defgeneric do-symbols-expander
    (client symbol-variable package-designator-form result-form body))

;;; This function is used by the macro DO-EXTERNAL-SYMBOLS to compute
;;; the expansion.
(defgeneric do-external-symbols-expander
    (client symbol-variable package-designator-form result-form body))
