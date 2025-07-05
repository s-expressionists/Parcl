(cl:in-package #:parcl-low)

(defmethod rename-package
    ((client t) (package t) (new-name string) (new-nicknames list))
  (let* ((old-names     (list* (name client package) (nicknames client package)))
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
    (setf (name      client package) new-name
          (nicknames client package) new-nicknames)
    ;; Update environment
    (loop for name in added-names
          do (setf (find-package client name) package))
    (loop for name in removed-names
          do (setf (find-package client name) nil))
    ;; Return renamed package.
    package))
