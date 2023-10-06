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

;;; There can be a large number of present symbols in a package.
;;; However, we think that the most frequent operation is FIND-SYMBOL,
;;; and perhaps also INTERN.  As a result, we use a dual
;;; representation for the present symbols, namely a "symbol table"
;;; (usually a hash table) provided by client code, and a simple list
;;; of all symbols to be used by iterators and LOOP clauses.  When we
;;; need to remove a symbol (by UNINTERN), we must then traverse the
;;; list, but we think this operation is infrequent.  A symbol in the
;;; symbol table and in the list is represented by an "entry" in the
;;; form of a CONS cell.  The CAR of the CONS cell is the symbol, and
;;; the CDR is the "status" of the symbol.  The status can be one of
;;; :INTERNAL, :INTERNAL-SHADOWING, :EXTERNAL, and
;;; :EXTERNAL-SHADOWING.

;;; Return the symbol table of PACKAGE.  The name of the symbol is the
;;; key.
(defgeneric symbol-table (package))

;;; Return the list of entries of every present symbol in PACKAGE.
(defgeneric symbol-entries (package))

;;; Set the list of entries of every present symbol in PACKAGE.
(defgeneric (setf symbol-entries) (new-entries package))

(defclass package (parcl:package)
  ((%name
      :initarg :name
      :accessor name)
   (%nicknames
      :initarg :nicknames
      :initform '()
      :accessor nicknames)
   (%local-nicknames
      :initarg :local-nicknames
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
   (%symbol-table
      :initarg :symbol-table
      :reader symbol-table)
   (%symbol-entries
      :initform '()
      :accessor symbol-entries)))

(defun make-entry (symbol status)
  (cons symbol status))

(defun entry-symbol (entry)
  (car entry))

(defun entry-status (entry)
  (cdr entry))
