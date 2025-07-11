(cl:in-package #:parcl-low-class)

(defmethod parcl-low:packagep ((client client) (package package))
  t)

(defmethod parcl-low:name ((client client) package)
  (name package))

(defmethod (setf parcl-low:name) (new-name (client client) package)
  (setf (name package) new-name))

(defmethod parcl-low:nicknames ((client client) package)
  (nicknames package))

(defmethod (setf parcl-low:nicknames) (new-nicknames (client client) package)
  (setf (nicknames package) new-nicknames))

#++ (defmethod (setf parcl-low:symbol-entries) ; TODO
    (symbol-entries (client client) package)
  (setf (symbol-entries package) symbol-entries))

(defmethod parcl-low:use-list ((client client) package)
  (use-list package))

(defmethod (setf parcl-low:use-list) (new-packages (client client) package)
  (setf (use-list package) new-packages))

(defmethod parcl-low:used-by-list ((client client) package)
  (used-by-list package))

(defmethod (setf parcl-low:used-by-list) (new-packages (client client) package)
  (setf (used-by-list package) new-packages))

(defmethod parcl-low:make-package-object ((client client) (name t))
  (make-instance 'package :name name
    ; :symbol-table (parcl-low:make-table client)
    ))

#++(defmethod parcl-low:find-present-symbol ((client client) package name) ; TODO
  (let ((entry (parcl-low:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (values nil nil)
        (values (entry-symbol entry)
                (case (entry-status entry)
                  ((:internal :internal-shadowing) :internal)
                  (otherwise :external))))))

#++(defmethod parcl-low:intern ((client client) package name) ; TODO
  (multiple-value-bind (symbol status)
      (parcl-low:find-symbol client package name)
    (if (null status)
        (let* ((symbol (parcl-low:make-symbol client name package))
               (entry (make-entry symbol :internal)))
          (add-entry client name entry package)
          (values symbol nil))
        (values symbol status))))

#++(defmethod parcl-low:shadow ((client client) package name) ; TODO
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

#++(defmethod parcl-low:ensure-present-symbol ; TODO
    ((client client) package symbol &optional status)
  (let* ((name (parcl-low:symbol-name client symbol))
         (entry (parcl-low:name-to-entry client name (symbol-table package))))
    (if (null entry)
        (let* ((status (if (null status) :internal status))
               (entry (make-entry symbol status)))
          (add-entry client name entry package))
        (setf (entry-status entry)
              (let ((old-status (entry-status entry)))
                (case status
                  (:internal
                   (case old-status
                     (:external :internal)
                     (:external-shadowing :internal-shadowing)
                     (otherwise old-status)))
                  (:external
                   (case (entry-status entry)
                     (:internal :external)
                     (:internal-shadowing :external-shadowing)
                     (otherwise old-status)))
                  (otherwise old-status)))))))

#++(defmethod parcl-low:remove-present-symbol ((client client) package symbol) ; TODO
  (parcl-low:remove-entry
   client (symbol-name symbol) (symbol-table package))
  (setf (symbol-entries package)
        (remove symbol (symbol-entries package) :test #'eq :key #'car))
  (when (eq (parcl-low:symbol-package client symbol) package)
    (setf (parcl-low:symbol-package client symbol) nil)))

(defmethod parcl-low:local-nicknames ((client client) package)
  (local-nicknames package))

(defmethod (setf parcl-low:local-nicknames)
    (new-local-nicknames (client client) package)
  (setf (local-nicknames package) new-local-nicknames))

(defmethod parcl-low:locally-nicknamed-by ((client client) package)
  (locally-nicknamed-by package))

(defmethod (setf parcl-low:locally-nicknamed-by)
    (new-packages (client client) package)
  (setf (locally-nicknamed-by package) new-packages))

;;; Package-symbol relation functions

(defmethod parcl-low:map-symbol-entries
    ((client client) (function t) (package t) &optional status)
  (maphash (lambda (name entry)
             (declare (ignore name)) ; TODO: alexandria maphash-values
             (multiple-value-call function (entry-values entry)))
           (symbol-table package)))

#++ (defmethod parcl-low:symbol-entries ((client client) (package t) &optional status) ; TODO: maybe not needed
  (symbol-entries package))

(defmethod parcl-low:symbol-entry ((client client) (name t) (package t))
  (let ((entry (gethash name (symbol-table package))))
    (if (null entry)
        (values nil nil nil)
        (entry-values entry))))

(defmethod parcl-low:set-symbol-entry ((symbol        t)
                                       (export-status t)
                                       (shadow-status t)
                                       (client        client)
                                       (name          t)
                                       (package       t))
  (let* ((table (symbol-table package))
         (entry (gethash name table)))
    (if (null entry)
        (setf (gethash name table)
              (make-entry symbol export-status shadow-status))
        (setf (entry-values entry)
              (values symbol export-status shadow-status)))))
