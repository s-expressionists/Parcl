(cl:in-package #:parcl.middle)

(defmethod delete-package ((client t) (package t))
  ;; If other packages are using PACKAGE `unuse-package' has to be
  ;; called for each such relation or the operation cannot complete.
  (loop for using-package in (low:used-by-list client package)
        do (restart-case
               (error 'parcl::package-in-use-error :package package
                                                   :used-by using-package)
             (unuse-package ()
               :report (lambda (stream)
                         (parcl::report-restart 'unuse-package
                                                stream
                                                package
                                                using-package))
               (unuse-package client using-package package))))
  ;; Remove PACKAGE as the home package.
  ;; TODO: maps over wrong set of symbols
  (low:map-symbol-entries
   client
   (lambda (symbol export-status shadow-status)
     (declare (ignore export-status shadow-status))
     (setf (low:symbol-package client symbol) nil))
   package)
  ;; Update environment
  (loop for name in (list* (low:name client package)
                           (low:nicknames client package))
        do (setf (low:find-package client name) nil))
  ;; Mark as deleted
  (setf (low:name client package) nil)
  t)
