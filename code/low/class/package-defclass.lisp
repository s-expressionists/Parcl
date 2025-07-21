(cl:in-package #:parcl-low-class)

(defclass package (parcl-low:package)
  ((%name                 :initarg  #1=:name
                          :accessor name)
   (%nicknames            :initarg  :nicknames
                          :type     list ; of string
                          :accessor nicknames
                          :initform '())
   (%local-nicknames      :initarg  :local-nicknames
                          :type     list ; of TODO
                          :accessor local-nicknames
                          :initform '())
   (%locally-nicknamed-by :initarg  :locally-nicknamed-by
                          :type     list ; of TODO
                          :accessor locally-nicknamed-by
                          :initform '())
   (%use-list             :initarg  :use-list
                          :type     list ; of (satisfies packagep)
                          :accessor use-list
                          :initform '())
   (%used-by-list         :initarg  :used-by-list
                          :type     list ; of (satisfies packagep)
                          :accessor used-by-list
                          :initform '())
   ;; There can be a large number of present symbols in a package.
   ;; However, we think that the most frequent operation is
   ;; FIND-SYMBOL, and perhaps also INTERN.  As a result, we use a
   ;; dual representation for the present symbols, namely a "symbol
   ;; table" (usually a hash table) provided by client code, and a
   ;; simple list of all symbols to be used by iterators and LOOP
   ;; clauses.  When we need to remove a symbol (by UNINTERN), we must
   ;; then traverse the list, but we think this operation is
   ;; infrequent.
   ;;
   ;; A symbol in the symbol table and in the list is represented by
   ;; an "entry" in the form of a CONS cell.  The CAR of the CONS cell
   ;; is the symbol, and the CDR is the "status" of the symbol.  The
   ;; status can be one of :INTERNAL, :INTERNAL-SHADOWING, :EXTERNAL,
   ;; and :EXTERNAL-SHADOWING.
   (%symbol-table   :initarg  :symbol-table
                    :reader   symbol-table
                    :initform (make-hash-table :test #'equal))
   #++ (%symbol-entries :initform '()   ; TODO: unused at the moment
                        :accessor symbol-entries))
  (:default-initargs
   #1# (error "The initarg ~S is required by class ~S" '#1# 'package)))

(defmethod print-object ((object package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~S" (name object))))

(defun make-entry (symbol export-status shadow-status)
  (cons symbol (cons export-status shadow-status)))

(defun entry-values (entry)
  (values (car entry) (cadr entry) (cddr entry)))
