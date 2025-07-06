(cl:in-package #:parcl.middle)

(defmethod unexport ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (putative-symbol status)
        (low:symbol-entry client package name)
      (cond ((and (eq putative-symbol symbol)
                  (or (eq status :external) (eq status :external-shadowing)))
             (setf (low:symbol-entry client name package) (values symbol (case status
                                                                           (:external :internal)
                                                                           (:external-shadowing :internal-shadowing))))
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
