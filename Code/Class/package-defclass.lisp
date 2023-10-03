(cl:in-package #:parcl-class)

(defgeneric name (package))

(defgeneric (setf name) (new-name package))

(defgeneric nicknames (package))

(defgeneric (setf nicknames) (new-nicknames package))

(defgeneric local-nicknames (package))

(defgeneric (setf local-nicknames) (new-local-nicknames package))

(defgeneric use-list (package))

(defgeneric (setf use-list) (new-use-list package))

(defgeneric used-by-list (package))

(defgeneric (setf used-by-list) (new-used-by-list package))

;;; There can be a large number of external and internal symbols.
;;; However, we think that the most frequent operation is FIND-SYMBOL,
;;; and perhaps also INTERN.  As a result, we use a dual
;;; representation for each of these sets of symbols, namely a hash
;;; table to be used by FIND-SYMBOL and a simple list of all symbols
;;; to be used by iterators and LOOP clauses.  When we need to remove
;;; a symbol from one of the sets, we must then traverse the list, but
;;; we think this operation is infrequent.

;;; Return the hash table holding external symbols.  The name of the
;;; symbol is the key.
(defgeneric external-symbols-table (package))

;;; Return the list of external symbols.
(defgeneric external-symbols-list (package))

;;; Set the list of external symbols.
(defgeneric (setf external-symbols-list) (new-symbols-list package))

;;; Return the hash table holding internal symbols.  The name of the
;;; symbol is the key.
(defgeneric internal-symbols-table (package))

;;; Return the list of internal symbols.
(defgeneric internal-symbols-list (package))

;;; Set the list of internal symbols.
(defgeneric (setf internal-symbols-list) (new-symbols-list package))

;;; We represent the shadowing symbols as a simple list, assuming that
;;; in general there won't be very many of them.

(defgeneric shadowing-symbols (package))

(defgeneric (setf shadowing-symbols) (new-shadowing-symbols package))

(defclass package (parcl:package)
  ((%name
      :initarg :name
      :accessor name)
   (%nicknames
      :initarg :nicknames
      :initform '()
      :accessor nicknames)
   (%local-nicknames
      :initarg :nicknames
      :initform '()
      :accessor local-nicknames)
   (%use-list
      :initarg :use-list
      :initform '()
      :accessor use-list)
   (%used-by-list
      :initarg :used-by-list
      :initform '()
      :accessor used-by-list)
   (%external-symbols-table
      :initarg :external-symbols
      :reader external-symbols)
   (%external-symbols-list
      :initform '()
      :accessor external-symbols-list)
   (%internal-symbols-table
      :initarg :internal-symbols
      :reader internal-symbols)
   (%internal-symbols-list
      :initform '()
      :accessor internal-symbols-list)
   (%shadowing-symbols
      :initarg :shadowing-symbols
      :initform '()
      :accessor shadowing-symbols)))
