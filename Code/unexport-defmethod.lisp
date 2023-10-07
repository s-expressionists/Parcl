(cl:in-package #:parcl)

(defmethod unexport (client package symbol)
  (multiple-value-bind (putative-symbol status)
      (find-present-symbol client package (symbol-name client symbol))
    (if (and (eq putative-symbol symbol)
             (eq status :external))
        (progn (ensure-present-symbol client package symbol :internal)
               t)
        (restart-case 
            (error 'symbol-is-not-accessible
                   :package package
                   :symbol symbol)
          (continue ()
            :report
            (lambda (stream)
              (format stream "Continue"))
            (return-from unexport t))))))
