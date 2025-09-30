(cl:in-package #:parcl.middle)

(defmethod shadow ((client t) (package t) (name t))
  (multiple-value-bind (present-symbol export-status shadow-status)
      (low:symbol-entry client name package)
    (multiple-value-bind (symbol new-export-status)
        (if (null export-status)
            (values (low:make-symbol client name package) :internal) ; sets home package
            (values present-symbol                        export-status))
      (unless (and (eq new-export-status export-status) shadow-status)
        (setf (low:symbol-entry client name package)
              (values symbol new-export-status t)))
      symbol)))
