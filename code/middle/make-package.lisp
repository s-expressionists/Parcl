(cl:in-package #:parcl-low)

(defmethod make-package ((client t) (name t) (nicknames t) (used-packages t))
  (check-names-unoccupied ((name existing-package signal-error)
                           client (list* name nicknames))
    (restart-case
        (signal-error)
      (#1=parcl::return-existing ()
        :report (lambda (stream)
                  (parcl::report-restart '#1# stream existing-package))
        (return-from make-package existing-package))))
  (let ((result (make-package-object client name)))
    (setf (find-package client name) result)
    (loop for nickname in nicknames
          do (setf (find-package client nickname) result))
    (setf (nicknames client result) nicknames)
                                        ; (parcl:store-package result name nicknames)
    (use-packages client result used-packages)
    result))
