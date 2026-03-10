(cl:in-package #:parcl.middle)

(defmethod make-package ((client t) (name t) (nicknames t) (used-packages t))
  (check-names-unoccupied ((name existing-package signal-error)
                           client (list* name nicknames))
    (restart-case
        (signal-error)
      (#1=parcl::return-existing ()
        :report (lambda (stream)
                  (parcl::report-restart '#1# stream existing-package))
        (return-from make-package existing-package))))
  (let ((result (low:make-package-object client name)))
    (loop for name in (list* name nicknames)
          do (setf (low:find-package client name) result))
    (setf (low:nicknames client result) nicknames)
    ;; Checking for USED-PACKAGES being empty is an optimization but
    ;; also necessary for creating the KEYWORD package since
    ;; `use-packages' signals an error when called with the KEYWORD
    ;; package.
    (unless (null used-packages)
      (use-packages client result used-packages))
    result))
