(cl:in-package #:parcl-low)

(defmethod import (client package symbol)
  (let ((name (symbol-name client symbol)))
    ;; Check for name conflict with present symbols.
    (multiple-value-bind (present-symbol status)
        (find-present-symbol client package name)
      (unless (or (null status) (eq symbol present-symbol))
        ;; We have a conflict.
        (restart-case
            (error 'symbol-conflict
                   :conflicting-symbols (list symbol present-symbol))
          (unintern-existing-symbol ()
            (unintern client package present-symbol)
            ;; TODO(jmoringe): should we skip the other conflict check?
            )
          (do-not-import ()
            (return-from import t)))))
    ;; Check for name conflict with inherited symbols.
    (loop for used-package in (use-list client package)
          do (multiple-value-bind (inherited-symbol status)
                 (find-present-symbol client used-package name)
               (when (eq status :external)
                 (if (eq symbol inherited-symbol)
                     (ensure-present-symbol client package symbol)
                     ;; We have a conflict.
                     (restart-case
                         (error 'symbol-conflict
                                :conflicting-symbols
                                (list symbol inherited-symbol))
                       (make-a-shadowing-symbol ()
                         (shadowing-import client package symbol)
                         (return-from import t))
                       (do-not-import ()
                         (return-from import t)))))))
    ;;
    (ensure-present-symbol client package symbol :internal)
    (setf (symbol-package client symbol) package)
    t))
