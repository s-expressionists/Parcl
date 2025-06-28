(cl:in-package #:parcl-low)

(defmethod intern ((client t) (package t) (name string))
  ;; TODO(jmoringe): should start by asserting that package has not been deleted? or should the higher layer do that?
  ;; TODO(jmoringe): same code for finding existing symbols in import
  (multiple-value-bind (present-symbol status)
      (find-present-symbol client package name)
    (cond ((not (null status))
           (values present-symbol status))
          (t
           (loop for used-package in (use-list client package)
                 do (multiple-value-bind (inherited-symbol status)
                        (find-present-symbol client used-package name)
                      (when (eq status :external)
                        (return-from intern (values inherited-symbol :inherited)))))
           (let ((symbol (make-symbol client name package)))
             (ensure-present-symbol client package symbol :internal)
             (values symbol :internal))))))
