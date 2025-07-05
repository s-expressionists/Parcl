(cl:in-package #:parcl-low)

;;;; This file contains essential accessors for package objects.  They
;;;; are deliberately distinct from any standard Common Lisp function,
;;;; because we might want different implementations of these
;;;; accessors in different contexts.

;;;; Names and inter-package relations

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
(defgeneric local-nicknames (client package))

(defgeneric (setf local-nicknames) (new-value client package))

;;; This function is used to implement the semi-standard function
;;; PACKAGE-LOCALLY-NICKNAMED-BY-LIST.  The PACKAGE argument of this
;;; function must be a package object.
(defgeneric locally-nicknamed-by (client package))

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

;;;; Package as symbol container

;;; This function is used to implement the standard function
;;; PACKAGE-SHADOWING-SYMBOLS.  Contrary to the Common Lisp standard
;;; function, the PACKAGE argument of this function must be a package
;;; object, whereas the standard function takes a package designator.
;;; The return value is a list of symbols that have been defined as
;;; shadowing symbols of PACKAGE.  This list is not freshly allocated,
;;; so if client code wants a fresh list, it must copy what this
;;; function returns.
#++ (defgeneric shadowing-symbols (client package))

;;; This function is used to implement the standard functions SHADOW
;;; and SHADOWING-IMPORT.  The PACKAGE argument of this function must
;;; be a package object.  NEW-SYMBOLS becomes the new list of
;;; shadowing symbols of PACKAGE.  The return value of this function
;;; is NEW-SYMBOLS as required by the Common Lisp standard.
#++ (defgeneric (setf shadowing-symbols) (new-symbols client package))

(defgeneric map-external-symbols (client package function))

(defgeneric map-symbols (client package function))

;;; Given a string, if a symbol with that name is present in PACKAGE,
;;; then return two values, the symbol and its status.  The status can
;;; be either :INTERNAL or :EXTERNAL. If there is no present symbol
;;; with that name in PACKAGE, then return NIL and NIL.
(defgeneric find-present-symbol (client package name))

;;; TODO: should probably set home package?
(defgeneric ensure-present-symbol (client package symbol &optional status))

;;; TODO: proper description | Remove from entries and unset home package
(defgeneric remove-present-symbol (client package symbol))

;;;;

;;; The SYMBOL ENTRIES of a package is a list of CONS cells, each
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

(defgeneric set-symbol-entry (symbol status client name package))

(defsetf symbol-entry (client name package) (symbol status)
  `(set-symbol-entry ,symbol ,status ,client ,name ,package))
