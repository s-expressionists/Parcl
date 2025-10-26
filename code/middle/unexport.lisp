(cl:in-package #:parcl.middle)

(defmethod unexport ((client t) (package t) (symbol t))
  (let ((package-name (low:name client package)))
    (when (or (string= package-name "COMMON-LISP")
              (string= package-name "KEYWORD"))
      (error 'parcl:unexport-forbidden-for-system-package-error
             :package            package
             :symbol-to-unexport symbol)))
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
                 :report ; TODO
                 (lambda (stream)
                   (format stream "Continue")))))
            ((eq export-status :external)
             (setf (low:symbol-entry client name package)
                   (values symbol :internal shadow-status))))))
  ;; TODO: return value
  )
