(cl:in-package #:parcl.middle)

(defmethod #1=unexport ((client t) (package t) (symbol t))
  ;; The specification directly forbids unexporting for symbols in the
  ;; COMMON-LISP and KEYWORD packages.
  (let ((package-name (low:name client package)))
    (when (or (string= package-name "COMMON-LISP")
              (string= package-name "KEYWORD"))
      (restart-case
          (error 'parcl:unexport-forbidden-for-system-package-error
                 :package            package
                 :symbol-to-unexport symbol)
        (#2=parcl::do-nothing ()
          :report (lambda (stream)
                    (parcl::report-restart '#2# stream '#1#))
          (return-from unexport nil)))))
  ;; Logic for "normal" packages.
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (putative-symbol export-status shadow-status)
        (low:symbol-entry client name package)
      (cond ((or (not (eq putative-symbol symbol))
                 (null export-status))
             (restart-case
                 (error 'parcl:symbol-is-not-accessible-error
                        :package             package
                        :inaccessible-symbol symbol)
               (#3=parcl::do-nothing ()
                 :report (lambda (stream)
                           (parcl::report-restart '#3# stream '#1#))))
             nil)
            ((eq export-status :external)
             (setf (low:symbol-entry client name package)
                   (values symbol :internal shadow-status))
             t)))))
