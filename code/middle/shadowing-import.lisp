(cl:in-package #:parcl.middle)

(defmethod shadowing-import ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (present-symbol old-export-status)
        (low:symbol-entry client name package)
      (unless (or (null old-export-status) (eq symbol present-symbol))
        ;; We have a conflict.  We must first unintern the conflicting
        ;; symbol.
        (unintern client package present-symbol))
      (let ((new-export-status (or old-export-status :internal)))
        (unchecked-import client package name symbol new-export-status t))
      ;; Return the symbol that has been replaced, if any.
      present-symbol)))
