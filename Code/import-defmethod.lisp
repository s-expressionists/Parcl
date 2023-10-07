(cl:in-package #:parcl)

(defmethod import (client package symbol)
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (let ((name (symbol-name client symbol)))
    (multiple-value-bind (present-symbol status)
        (find-present-symbol client package name)
      (unless (null status)
        (unless (eq symbol present-symbol)
          ;; We have a conflict.
          (restart-case
              (error 'symbol-conflict
                     :conflicting-symbols (list symbol present-symbol))
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
