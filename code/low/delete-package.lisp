(cl:in-package #:parcl-low)

(defmethod delete-package ((client t) (package t))
  ;; If other packages are using PACKAGE `unuse-package' has to be
  ;; called for each such relation or the operation cannot complete.
  (loop for using-package in (used-by-list client package)
        do (restart-case
               (error 'package-in-use-error
                      :package packge
                      :using-package using-package)
             (unuse-package ()
               :report (lambda (stream)
                         (parcl::report-restart 'unuse-package
                                                stream
                                                package
                                                using-package))
               (unuse-package client using-package package))))
  ;; Remove PACKAGE as the home package.
  ;; TODO: maps over wrong set of symbols
  (map-symbols client package (lambda (symbol)
                                (setf (symbol-package symbol) nil)))
  ;;
  (setf (deletedp client package) t) ; TODO: indicate this some other way?
  t)
