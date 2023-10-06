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

(defmethod parcl:make-package ((client client) name)
  (make-instance 'package
    :name name
    :external-symbols (parcl:make-symbol-table client)
    :internal-symbols (parcl:make-symbol-table client)))

(defmethod parcl:find-present-symbol ((client client) package name)
  (let ((entry (parcl:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (values nil nil)
        (values (entry-symbol entry)
                (case (entry-status entry)
                  ((:internal :internal-shadowing) :internal)
                  (otherwise :external))))))
  
(defmethod parcl:intern ((client client) package name)
  (multiple-value-bind (symbol status)
      (parcl:find-symbol client package name)
    (if (null status)
        (let* ((symbol (parcl:make-symbol client name package))
               (entry (make-entry symbol :internal)))
          (setf (parcl:name-to-entry client name (symbol-table package))
                entry)
          (push entry (symbol-entries package))
          (values result nil))
        (values symbol status))))
