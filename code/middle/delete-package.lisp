(cl:in-package #:parcl.middle)

(defmethod delete-package ((client t) (package t))
  (let ((name (low:name client package)))
    (cond ((null name) ; already deleted
           nil)
          (t
           ;; If other packages are using PACKAGE, `unuse-package' has
           ;; to be called for each such relation or the operation
           ;; cannot complete.
           (loop :for using-package :in (low:used-by-list client package)
                 :do (restart-case
                         (error 'parcl:package-in-use-error
                                :package package
                                :used-by using-package)
                       (#1=parcl:unuse-package ()
                         :report (lambda (stream)
                                   (parcl::report-restart
                                    '#1# stream package using-package))
                         (unuse-package client using-package package))))
           ;; If PACKAGE uses other packages, call `unuse-package' to
           ;; remove each of those relations.
           (loop :for used-package :in (low:use-list client package)
                 :do (unuse-package client package used-package))
           ;; Remove PACKAGE as the home package of present symbols.
           (low:map-symbol-entries
            client (lambda (symbol export-status shadow-status)
                     (declare (ignore export-status shadow-status))
                     (when (eq (low:symbol-package client symbol) package)
                       (setf (low:symbol-package client symbol) nil)))
            package)
           ;; Update environment
           (setf (low:find-package client name) nil)
           (loop :for name :in (low:nicknames client package)
                 :do (setf (low:find-package client name) nil))
           ;; Mark as deleted
           (setf (low:name client package) nil)
           t))))
