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
  (loop for entry in (symbol-entries package)
        for status = (entry-status entry)
        when (or (eq status :internal-shadowing)
                 (eq status :external-shadowing))
          collect (entry-symbol entry)))

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
    :symbol-table (parcl:make-table client)))

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
          (add-entry client name entry package)
          (values symbol nil))
        (values symbol status))))

(defmethod parcl:shadow ((client client) package name)
  (let ((entry (parcl:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (let* ((symbol (parcl:make-symbol client name package))
               (entry (make-entry symbol :internal-shadowing)))
          (add-entry client name entry package))
        (setf (entry-status entry)
              (case (entry-status entry)
                ((:internal :internal-shadowing) :internal-shadowing)
                (otherwise :external-shadowing)))))
  t)

(defmethod parcl:ensure-present-symbol
    ((client client) package symbol &optional status)
  (let* ((name (parcl:symbol-name client symbol))
         (entry (parcl:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (let* ((status (if (null status) :internal status))
               (entry (make-entry symbol status)))
          (add-entry client name entry package))
        (setf (entry-status entry)
              (case status
                (:internal
                 (case (entry-status entry)
                   (:external :internal)
                   (:external-shadowing :internal-shadowing)
                   (otherwise (entry-status entry))))
                (:external
                 (case (entry-status entry)
                   (:internal :external)
                   (:internal-shadowing :external-shadowing)
                   (otherwise (entry-status entry))))
                (otherwise (entry-status entry)))))))
