(cl:in-package #:parcl)

(defmethod import (client package symbol)
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (let ((name (symbol-name client symbol)))
    (multiple-value-bind (external-symbol present-p)
        (find-external-symbol client package name)
      (when present-p
        (unless (eq symbol external-symbol)
          ;; We have a conflict.
          (restart-case
              (error 'symbol-conflict
                     :conflicting-symbols (list symbol external-symbol))
            (unintern-existing-symbol ()
              (unintern client package symbol))
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
              (unintern client package symbol))
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
              (unintern client package symbol))
            (do-not-import ())))
        (return-from import t)))
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
                         (shadowing-import client package symbol))
                       (do-not-import ())))
                 (return-from import t))))))
