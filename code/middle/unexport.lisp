(cl:in-package #:parcl.middle)

(defmethod unexport ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (putative-symbol export-status shadow-status)
        (low:symbol-entry client name package)
      (cond ((or (not (eq putative-symbol symbol))
                 (null export-status))
             (restart-case
                 (error 'parcl:symbol-is-not-accessible-error
                        :package              package
                        :inaccessible-symbol  symbol)
               (continue ()
                 :report
                 (lambda (stream)
                   (format stream "Continue"))
                 t))
             t)
            ((eq export-status :external)
             (setf (low:symbol-entry client name package)
                   (values symbol :internal shadow-status))))))
  ;; TODO: return value
  )
