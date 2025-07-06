(cl:in-package #:parcl-low)

;;; This function returns true if and only if the two symbols have the
;;; same name.
(defgeneric symbol-names-equal (client symbol1 symbol2))

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

;;; This function takes a string and a table and removes the entry
;;; with that name from the table.  It is assumed that the entry is
;;; present in the table.
(defgeneric remove-entry (client name table))
