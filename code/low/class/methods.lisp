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

(defmethod parcl-low:use-list ((client client) package)
  (use-list package))

(defmethod (setf parcl-low:use-list) (new-packages (client client) package)
  (setf (use-list package) new-packages))

(defmethod parcl-low:used-by-list ((client client) package)
  (used-by-list package))

(defmethod (setf parcl-low:used-by-list) (new-packages (client client) package)
  (setf (used-by-list package) new-packages))

(defmethod parcl-low:make-package-object ((client client) (name t))
  (make-instance 'package :name name))

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
  (declare (ignore status))
  (maphash (lambda (name entry)
             (declare (ignore name)) ; TODO: alexandria maphash-values
             (multiple-value-call function (entry-values entry)))
           (symbol-table package)))

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
  (let ((table (symbol-table package)))
    (if (null export-status)
        (remhash name table)
        (setf (gethash name table)
              (make-entry symbol export-status shadow-status)))))
