(cl:in-package #:parcl)

(defmethod find-symbol (client package name)
  (multiple-value-bind (symbol present-p)
      (find-internal-symbol client package name)
    (if present-p
        (values symbol :internal)
        (multiple-value-bind (symbol present-p)
            (find-external-symbol client package name)
          (if present-p
              (values symbol :external)
              (loop for used-package in (use-list client package)
                    do (multiple-value-bind (symbol present-p)
                           (find-external-symbol client used-package name)
                         (when present-p
                           (return symbol :inherited)))
                    finally (return nil nil)))))))
