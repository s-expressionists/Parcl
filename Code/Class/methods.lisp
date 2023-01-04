(cl:in-packaage #:parcl-class)

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

(defmethod (setf parcl:shadowing-symbols) (new-symbol (client client) package)
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
        (first (external-symbols-list package))))

(defmethod parcl:remove-external-symbol ((client client) package symbol)
  (let* ((table (external-symbols-table package))
         (cell (gethash (symbol-name symbol) table)))
    (if (null (rest cell))
        (setf (external-symbol-list package)
              (nbutlast (external-symbol-list package)))
        (let ((next-symbol (second cell)))
          (setf (gethash (symbol-name next-symbol) table)
                cell)
          (setf (rest cell) (rest (rest cell)))))
    (remhash (symbol-name symbol) table)))

(defmethod parcl:find-internal-symbol ((client client) package name)
  (let ((cell (gethash name (internal-symbols-table package))))
    (if (null cell)
        (values nil nil)
        (values (car cell) t))))

(defmethod parcl:add-internal-symbol ((client client) package symbol)
  (push symbol (internal-symbols-list package))
  (setf (gethash (symbol-name symbol) (internal-symbols-table package))
        (first (internal-symbols-list package))))

(defmethod parcl:remove-internal-symbol ((client client) package symbol)
  (let* ((table (internal-symbols-table package))
         (cell (gethash (symbol-name symbol) table)))
    (if (null (rest cell))
        (setf (internal-symbol-list package)
              (nbutlast (internal-symbol-list package)))
        (let ((next-symbol (second cell)))
          (setf (gethash (symbol-name next-symbol) table)
                cell)
          (setf (rest cell) (rest (rest cell)))))
    (remhash (symbol-name symbol) table)))

(defmethod parcl:find-shadowing-symbol ((client client) package name)
  (let ((suffix (member name (shadowing-symbols package)
                        :key #'symbol-name
                        :test #'string=)))
    (if (null suffix)
        (values nil nil)
        (values (first suffix) t)))

(defmethod parcl:add-shadowing-symbol ((client client) package symbol)
  (push symbol (shadowing-symbols-list package)))

(defmethod parcl:remove-shadowing-symbol ((client client) package symbol)
  (setf (shadowing-symbols-list package)
        ;; We are counting on DELETE to modify the list so as to avoid
        ;; unnecessary consing.
        (delete symbol (shadowing-symbols-list package))))
