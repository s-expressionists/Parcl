(cl:in-package #:parcl-class)

(defmethod parcl:name ((client client) package)
  (name package))

(defmethod (setf parcl:name) (new-name (client client) package)
  (setf (name package) new-name))

(defmethod parcl:nicknames ((client client) package)
  (nicknames package))

(defmethod (setf parcl:nicknames) (new-nicknames (client client) package)
  (setf (nicknames package) new-nicknames))

(defmethod parcl:shadowing-symbols ((client client) package)
  (shadowing-symbols package))

(defmethod (setf parcl:shadowing-symbols) (new-symbols (client client) package)
  (setf (shadowing-symbols package) new-symbols))

(defmethod parcl:use-list ((client client) package)
  (use-list package))

(defmethod (setf parcl:use-list) (new-packages (client client) package)
  (setf (use-list package) new-packages))

(defmethod parcl:used-by-list ((client client) package)
  (used-by-list package))

(defmethod (setf parcl:used-by-list) (new-packages (client client) package)
  (setf (used-by-list package) new-packages))

(defmethod parcl:external-symbols ((client client) package)
  (external-symbols-list package))

(defmethod parcl:find-external-symbol ((client client) package name)
  (let ((cell (gethash name (external-symbols-table package))))
    (if (null cell)
        (values nil nil)
        (values (car cell) t))))

(defmethod parcl:add-external-symbol ((client client) package symbol)
  (push symbol (external-symbols-list package))
  (setf (gethash (symbol-name symbol) (external-symbols-table package))
        (external-symbols-list package)))

(defmethod parcl:internal-symbols ((client client) package)
  (internal-symbols-list package))

(defmethod parcl:find-internal-symbol ((client client) package name)
  (let ((cell (gethash name (internal-symbols-table package))))
    (if (null cell)
        (values nil nil)
        (values (car cell) t))))

(defmethod parcl:add-internal-symbol ((client client) package symbol)
  (push symbol (internal-symbols-list package))
  (setf (gethash (symbol-name symbol) (internal-symbols-table package))
        (internal-symbols-list package))
  (values))

;;; The technique we use for removing a symbol from the list works
;;; like this: The hash table contains the CONS cells of the list.
;;; Let us say that C1 is the cell containing the symbol, say S1, to
;;; be removed.  If the there is a cell, say C2 after C1 in the list
;;; containing the symbols S2, we move S2 to C1, and unlink C2 from
;;; the list.  We update the hash table so that the entry for S2 now
;;; points to C1.  If C1 is the last cell in the list, there are two
;;; cases.  Case 1 is when C1 is the only cell in the list.  We then
;;; just set the list of symbols to the empty list.  Case 2 is when
;;; there is at least one cell in addition to C1 in the list.  Then,
;;; in particular, the first cell in the list can not be C1, since C1
;;; is the last one in the list.  Call the first cell in the list C2,
;;; and the symbol therein S2.  We again move S2 to C1, and unlink C2
;;; from the list by simply popping off the first element.  We update
;;; the hash table so that the entry for S2 now points to C1.  In all
;;; cases, we end by removing the entry for S1 from the hash table.

(defmethod parcl:remove-external-symbol ((client client) package symbol)
  (let* ((table (external-symbols-table package))
         (cell (gethash (symbol-name symbol) table)))
    (if (null (rest cell))
        (if (null (rest (external-symbols-list package)))
            ;; There is only this one symbol left.
            (setf (external-symbols-list package) '())
            ;; Otherwise, we move the symbol from the first cell on
            ;; the list to this cell.
            (let ((symbol-to-move (first (external-symbols-list package))))
              (setf (first cell) symbol-to-move)
              (setf (gethash (symbol-name symbol-to-move) table) cell)
              (pop (first (external-symbols-list package)))))
        (let ((next-symbol (second cell)))
          (setf (gethash (symbol-name next-symbol) table) cell)
          (setf (rest cell) (rest (rest cell)))))
    (remhash (symbol-name symbol) table)))

(defmethod parcl:find-internal-symbol ((client client) package name)
  (let ((cell (gethash name (internal-symbols-table package))))
    (if (null cell)
        (values nil nil)
        (values (car cell) t))))

(defmethod parcl:remove-internal-symbol ((client client) package symbol)
  (let* ((table (internal-symbols-table package))
         (cell (gethash (symbol-name symbol) table)))
    (if (null (rest cell))
        (if (null (rest (internal-symbols-list package)))
            ;; There is only this one symbol left.
            (setf (internal-symbols-list package) '())
            ;; Otherwise, we move the symbol from the first cell on
            ;; the list to this cell.
            (let ((symbol-to-move (first (internal-symbols-list package))))
              (setf (first cell) symbol-to-move)
              (setf (gethash (symbol-name symbol-to-move) table) cell)
              (pop (first (internal-symbols-list package)))))
        (let ((next-symbol (second cell)))
          (setf (gethash (symbol-name next-symbol) table) cell)
          (setf (rest cell) (rest (rest cell)))))
    (remhash (symbol-name symbol) table)))

(defmethod parcl:find-shadowing-symbol ((client client) package name)
  (let ((suffix (member name (shadowing-symbols package)
                        :key #'symbol-name
                        :test #'string=)))
    (if (null suffix)
        (values nil nil)
        (values (first suffix) t))))

(defmethod parcl:add-shadowing-symbol ((client client) package symbol)
  (push symbol (shadowing-symbols package)))

(defmethod parcl:remove-shadowing-symbol ((client client) package symbol)
  (setf (shadowing-symbols package)
        ;; We are counting on DELETE to modify the list so as to avoid
        ;; unnecessary consing.
        (delete symbol (shadowing-symbols package))))

(defmethod parcl:make-package ((client client) name)
  (make-instance 'package
    :name name
    :external-symbols (parcl:make-symbol-table client)
    :internal-symbols (parcl:make-symbol-table client)))
