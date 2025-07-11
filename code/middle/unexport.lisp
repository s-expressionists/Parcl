(cl:in-package #:parcl.middle)

(defmethod unexport ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (putative-symbol export-status shadow-status)
        (low:symbol-entry client package name)
      (cond ((and (eq putative-symbol symbol)
                  (or (eq export-status :external)))
             (setf (low:symbol-entry client name package)
                   (values symbol :internal shadow-status))
             t)
            (t
             (restart-case
                 (error 'parcl::symbol-is-not-accessible :package package
                                                         :symbol  symbol)
               (continue ()
                 :report
                 (lambda (stream)
                   (format stream "Continue"))
                 t)))))))
