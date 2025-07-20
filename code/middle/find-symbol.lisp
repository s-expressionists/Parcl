(cl:in-package #:parcl.middle)

(defmethod find-symbol ((client t) (package t) (name string))
  (flet ((found-one (containing-package symbol export-status shadow-status)
           (declare (ignore shadow-status))
           (return-from find-symbol
             (values symbol (if (eq containing-package package)
                                export-status
                                :inherited)))))
    (map-accessible-entries-with-name client #'found-one name package)
    (values nil nil)))
