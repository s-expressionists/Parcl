(cl:in-package #:parcl-low)

(defun map-accessible-entries (client function package
                               &optional (other-packages
                                          (use-list client package)))
  (map-symbol-entries
   client
   (lambda (symbol status)
     (funcall function package symbol status))
   package)
  (loop for other-package in other-packages
        do (map-symbol-entries
            client
            (lambda (symbol status) ; TODO: split status into export-status shadowing-status
              (when (member status '(:external :external-shadowing))
                (funcall function other-package symbol status)))
            other-package))
  nil)

(defun map-accessible-entries-with-name (client function name package
                                         &optional (other-packages
                                                    (use-list client package)))
  (multiple-value-bind (present-symbol status)
      (symbol-entry client name package)
    (unless (null status)
      (funcall function package present-symbol status)))
  (loop for other-package in other-packages
        do (multiple-value-bind (inherited-symbol status)
               (symbol-entry client name other-package)
             (unless (or (null status) (eq status :external))
               (funcall function package inherited-symbol status))))
  nil)

(defmacro check-names-unoccupied (((name-var existing-package-var error-name)
                                   client names)
                                  &body body)
  `(loop for ,name-var in ,names
         for ,existing-package-var = (find-package ,client ,name-var)
         when (not (null ,existing-package-var))
           do (flet ((,error-name ()
                       (error 'parcl::package-name-occupied-error
                              ;; TODO: when used from rename-package it would be good to include this:
                              ;; :package          ,package
                              ;; TODO: maybe include the operation in all package-system-conditions? like :operation `(make-package ,name ...)
                              :new-name         ,name-var
                              :existing-package ,existing-package-var)))
                ,@body)))
