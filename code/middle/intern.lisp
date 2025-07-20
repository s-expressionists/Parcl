(cl:in-package #:parcl.middle)

(defmethod intern ((client t) (package t) (name string))
  ;; TODO(jmoringe): same code for finding existing symbols in import
  ;;                 same code in find-symbol
  ;; TODO: must export if PACKAGE is the keyword package
  (flet ((consider-symbol (other-package symbol export-status shadow-status)
           (declare (ignore shadow-status))
           (return-from intern
             (values symbol (if (eq other-package package)
                                export-status
                                :inherited)))))
    (map-accessible-entries-with-name client #'consider-symbol name package))
  (let ((symbol            (low:make-symbol client name package)) ; sets home package
        (new-export-status (if (string= (parcl-low:name client package) "KEYWORD") ; TODO: better way
                               :external
                               :internal)))
    (setf (low:symbol-entry client name package)
          (values symbol new-export-status nil))
    (values symbol nil)))
