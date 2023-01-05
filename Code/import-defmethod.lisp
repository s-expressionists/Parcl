(cl:in-package #:parcl)

(defmethod import (client package symbol)
  (let ((name (symbol-name symbol)))
    (multiple-value-bind (external-symbol present-p)
        (find-external-symbol client package name)
      (when present-p
        (unless (eq symbol external-symbol)
          ;; We have a conflict.
          (restart-case
              (error 'symbol-conflict
                     :conflicting-symbols (list symbol external-symbol))
            (unintern-existing-symbol ()
              (remove-external-symbol client package external-symbol)
              (add-internal-symbol client package symbol))
            (do-not-import ())))
        (return-from import t)))
    (multiple-value-bind (internal-symbol present-p)
        (find-internal-symbol client package name)
      (when present-p
        (unless (eq symbol internal-symbol)
          ;; We have a conflict.
          (restart-case
              (error 'symbol-conflict
                     :conflicting-symbols (list symbol internal-symbol))
            (unintern-existing-symbol ()
              (remove-internal-symbol client package internal-symbol)
              (add-internal-symbol client package symbol))
            (do-not-import ())))
        (return-from import t)))
    (multiple-value-bind (shadowing-symbol present-p)
        (find-shadowing-symbol client package name)
      (when present-p
        (unless (eq symbol shadowing-symbol)
          ;; We have a conflict.
          (restart-case
              (error 'symbol-conflict
                     :conflicting-symbols (list symbol shadowing-symbol))
            (unintern-existing-symbol ()
              (remove-shadowing-symbol client package shadowing-symbol)
              (add-internal-symbol client package symbol))
            (do-not-import ())))
        (return-from import t)))
    (loop for used-package in (use-list client package)
          do (multiple-value-bind (inherited-symbol present-p)
                 (find-external-symbol client used-package name)
               (when present-p
                 (if (eq symbol inherited-symbol)
                     (add-internal-symbol client package symbol)
                     ;; We have a conflict.
                     (restart-case
                         (error 'symbol-conflict
                                :conflicting-symbols
                                (list symbol inherited-symbol))
                       (make-a-shadowing-symbol ()
                         (add-shadowing-symbol client package symbol))
                       (do-not-import ())))
                 (return-from import t))))))
