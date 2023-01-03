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
  (gethash name (external-symbols-table package)))

(defmethod parcl:add-external-symbol ((client client) package symbol)
  (setf (gethash (symbol-name symbol) (external-symbols-table package))
        symbol)
  (push symbol (external-symbols-list package)))

(defmethod parcl:remove-external-symbol ((client client) package symbol)
  (remhash (symbol-name symbol) (external-symbols-table package))
  (setf (external-symbols-list package)
        ;; We are counting on DELETE to modify the list so as to avoid
        ;; unnecessary consing.
        (delete symbol (external-symbols-list package))))

(defmethod parcl:find-internal-symbol ((client client) package name)
  (gethash name (internal-symbols-table package)))

(defmethod parcl:add-internal-symbol ((client client) package symbol)
  (setf (gethash (symbol-name symbol) (internal-symbols-table package))
        symbol)
  (push symbol (internal-symbols-list package)))

(defmethod parcl:remove-internal-symbol ((client client) package symbol)
  (remhash (symbol-name symbol) (internal-symbols-table package))
  (setf (internal-symbols-list package)
        ;; We are counting on DELETE to modify the list so as to avoid
        ;; unnecessary consing.
        (delete symbol (internal-symbols-list package))))

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
