(cl:in-package #:parcl.middle)

(defmethod rename-package
    ((client t) (package t) (new-name string) (new-nicknames list))
  (let* ((old-names     (list* (low:name client package)
                               (low:nicknames client package)))
         (new-names     (list* new-name new-nicknames))
         (added-names   (set-difference new-names old-names :test #'string=))
         (removed-names (set-difference old-names new-names :test #'string=)))
    (check-names-unoccupied ((name existing-package signal-error) client added-names)
      (restart-case (signal-error)
        (#1=parcl::return-existing ()
          :report (lambda (stream)
                    (parcl::report-restart '#1# stream existing-package))
          (return-from rename-package existing-package))))
    ;; Update names
    (setf (low:name      client package) new-name
          (low:nicknames client package) new-nicknames)
    ;; Update environment
    (loop for name in added-names
          do (setf (low:find-package client name) package))
    (loop for name in removed-names
          do (setf (low:find-package client name) nil))
    ;; Return renamed package.
    package))
