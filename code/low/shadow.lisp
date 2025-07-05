(cl:in-package #:parcl-low)

(defmethod shadow ((client t) (package t) (name t))
  ;; TODO: the method for low-class uses the status - :internal-shadowing or :external-shadowing
  (multiple-value-bind (present-symbol status)
      (symbol-entry client name package)
    (let ((symbol (if (null status)
                      (make-symbol client name package) ; sets home package
                      present-symbol))
          (new-status (case status
                        ((nil :internal :internal-shadowing)
                         :internal-shadowing)
                        (t
                         :external-shadowing))))
      (setf (symbol-entry client name package) (values symbol new-status))
      symbol)))

#++ (defmethod parcl-low:shadow ((client low-class::client) package name)
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
