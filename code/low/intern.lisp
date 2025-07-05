(cl:in-package #:parcl-low)

(defmethod intern ((client t) (package t) (name string))
  ;; TODO(jmoringe): same code for finding existing symbols in import
  (flet ((consider-symbol (other-package symbol status)
           (return-from intern
             (values symbol (if (eq other-package package) status :inherited)))))
    (map-accessible-entries-with-name client #'consider-symbol name package))
  (let ((symbol (make-symbol client name package))) ; sets home package
    (setf (symbol-entry client name package) (values symbol :internal))
    (values symbol :internal))

  #++ (multiple-value-bind (present-symbol status)
          (symbol-entry client name package)
        (cond ((not (null status))
               (values present-symbol status))
              (t
               (loop for used-package in (use-list client package)
                     do (multiple-value-bind (inherited-symbol status)
                            (symbol-entry client name used-package)
                          (when (eq status :external)
                            (return-from intern
                              (values inherited-symbol :inherited)))))
               (let ((symbol (make-symbol client name package))) ; sets home package
                 (setf (symbol-entry client name package) (values symbol :internal))
                 (values symbol :internal))))))
