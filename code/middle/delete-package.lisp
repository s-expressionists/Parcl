(cl:in-package #:parcl.middle)

(defmethod delete-package ((client t) (package t))
  (let ((name (low:name client package)))
    (cond ((null name) ; already deleted
           nil)
          (t
           ;; If other packages are using PACKAGE, `unuse-package' has
           ;; to be called for each such relation or the operation
           ;; cannot complete.
           (loop for using-package in (low:used-by-list client package)
                 do (restart-case
                        (error 'parcl:package-in-use-error
                               :package package
                               :used-by using-package)
                      (unuse-package ()
                        :report (lambda (stream)
                                  (parcl::report-restart 'unuse-package
                                                         stream
                                                         package
                                                         using-package))
                        (unuse-package client using-package package))))
           ;; TODO
           (loop for used-package in (low:use-list client package)
                 do (unuse-package client package used-package))
           ;; Remove PACKAGE as the home package.
           ;; TODO: maps over wrong set of symbols
           (low:map-symbol-entries
            client (lambda (symbol export-status shadow-status)
                     (declare (ignore export-status shadow-status))
                     (when (eq (low:symbol-package client symbol) package)
                       (setf (low:symbol-package client symbol) nil)))
            package)
           ;; Update environment
           (loop for name in (list* name (low:nicknames client package))
                 do (setf (low:find-package client name) nil))
           ;; Mark as deleted
           (setf (low:name client package) nil)
           t))))
