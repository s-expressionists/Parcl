(cl:in-package #:parcl-low-class)

(defmethod parcl-low:name ((client client) package)
  (name package))

(defmethod (setf parcl-low:name) (new-name (client client) package)
  (setf (name package) new-name))

(defmethod parcl-low:nicknames ((client client) package)
  (nicknames package))

(defmethod (setf parcl-low:nicknames) (new-nicknames (client client) package)
  (setf (nicknames package) new-nicknames))

(defmethod parcl-low:shadowing-symbols ((client client) package)
  (loop for entry in (symbol-entries package)
        for status = (entry-status entry)
        when (or (eq status :internal-shadowing)
                 (eq status :external-shadowing))
          collect (entry-symbol entry)))

(defmethod parcl-low:use-list ((client client) package)
  (use-list package))

(defmethod (setf parcl-low:use-list) (new-packages (client client) package)
  (setf (use-list package) new-packages))

(defmethod parcl-low:used-by-list ((client client) package)
  (used-by-list package))

(defmethod (setf parcl-low:used-by-list) (new-packages (client client) package)
  (setf (used-by-list package) new-packages))

(defmethod parcl-low:make-package ((client client) name)
  (make-instance 'package
    :name name
    :symbol-table (parcl-low:make-table client)))

(defmethod parcl-low:find-present-symbol ((client client) package name)
  (let ((entry (parcl-low:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (values nil nil)
        (values (entry-symbol entry)
                (case (entry-status entry)
                  ((:internal :internal-shadowing) :internal)
                  (otherwise :external))))))

(defmethod parcl-low:intern ((client client) package name)
  (multiple-value-bind (symbol status)
      (parcl-low:find-symbol client package name)
    (if (null status)
        (let* ((symbol (parcl-low:make-symbol client name package))
               (entry (make-entry symbol :internal)))
          (add-entry client name entry package)
          (values symbol nil))
        (values symbol status))))

(defmethod parcl-low:shadow ((client client) package name)
  (let ((entry (parcl-low:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (let* ((symbol (parcl-low:make-symbol client name package))
               (entry (make-entry symbol :internal-shadowing)))
          (add-entry client name entry package))
        (setf (entry-status entry)
              (case (entry-status entry)
                ((:internal :internal-shadowing) :internal-shadowing)
                (otherwise :external-shadowing)))))
  t)

(defmethod parcl-low:ensure-present-symbol
    ((client client) package symbol &optional status)
  (let* ((name (parcl-low:symbol-name client symbol))
         (entry (parcl-low:name-to-entry client name (symbol-table package))))
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
