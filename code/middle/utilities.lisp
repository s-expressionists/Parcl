(cl:in-package #:parcl.middle)

(defun map-accessible-entries (client function package
                               &optional (other-packages
                                          (low:use-list client package)))
  (low:map-symbol-entries
   client
   (lambda (symbol export-status shadow-status)
     (funcall function package symbol export-status shadow-status))
   package)
  (loop for other-package in other-packages
        do (low:map-symbol-entries
            client
            (lambda (symbol export-status shadow-status)
              (when (eq export-status :external)
                ;; TODO: shadowing is not covered by unit tests
                (let* ((name (low:symbol-name client symbol))
                       ;; TODO: remember in iteration above whether there is any shadowing at all
                       (present-shadow-status (nth-value
                                               2 (low:symbol-entry client name package))))
                  (unless present-shadow-status
                    (funcall function other-package symbol export-status shadow-status)))))
            other-package))
  nil)

(defun map-accessible-entries-with-name (client function name package
                                         &optional (other-packages
                                                    (low:use-list client package)))
  (multiple-value-bind (present-symbol export-status shadow-status)
      (low:symbol-entry client name package)
    ;; TODO: test this
    (if (not (null export-status))
        (funcall function package present-symbol export-status shadow-status)
        (loop for other-package in other-packages
              do (multiple-value-bind (inherited-symbol export-status shadow-status)
                     (low:symbol-entry client name other-package)
                   (unless (or (null export-status) (eq export-status :internal))
                     (funcall function other-package inherited-symbol export-status shadow-status))))))
  nil)

(defmacro check-names-unoccupied (((name-var existing-package-var error-name)
                                   client names
                                   &optional (new-package nil new-package-supplied-p))
                                  &body body)
  `(loop for ,name-var in ,names
         for ,existing-package-var = (low:find-package ,client ,name-var)
         when (not (null ,existing-package-var))
           do (flet ((,error-name ()
                       ;; TODO: maybe include the operation in all package-system-conditions? like :operation `(make-package ,name ...)
                       ,(if new-package-supplied-p
                            `(error 'parcl::new-name-occupied-error
                                    :package          ,new-package
                                    :new-name         ,name-var
                                    :existing-package ,existing-package-var)
                            `(error 'parcl::package-name-occupied-error
                                    :new-name         ,name-var
                                    :existing-package ,existing-package-var))))
                ,@body)))
