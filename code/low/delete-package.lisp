(cl:in-package #:parcl-low)

(defmethod delete-package ((client t) (package t))
  ;; If other packages are using PACKAGE `unuse-package' has to be
  ;; called for each such relation or the operation cannot complete.
  (loop for using-package in (used-by-list client package)
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
  (map-symbol-entries
   client
   (lambda (symbol status)
     (declare (ignore status))
     (setf (symbol-package client symbol) nil))
   package)
  ;; Update environment
  (loop for name in (list* (name client package)
                           (nicknames client package))
        do (setf (find-package client name) nil))
  ;; Mark as deleted
  (setf (name client package) nil)
  t)
