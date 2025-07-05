(cl:in-package #:parcl-low)

(defmethod import ((client t) (package t) (symbol t))
  (prog ((name (symbol-name client symbol))
         (new-status :internal))
     (flet ((check-symbol (other-package other-symbol status)
              ;; TODO(jmoringe): can't we stop checking if the symbol is already present?
              (if (eq other-symbol symbol) ; no conflict if same symbol
                  (case status
                    ((:internal-shadowing :external-shadowing)
                     (setf new-status status)
                     (go :check-done))
                    (:external
                     (setf new-status status)))
                  (restart-case
                      (parcl::symbol-conflict package symbol other-symbol)
                    (unintern-existing-symbol ()
                      :test (lambda () (eq other-package package))
                      (unintern client package other-symbol)
                      ;; continue checking since
                      )
                    (make-a-shadowing-symbol ()
                      :test (lambda () (not (eq other-package package)))
                      (setf new-status :internal-shadowing)
                      (go :check-done))
                    (do-not-import ()
                      (return-from import t))))))
       (map-accessible-entries-with-name client #'check-symbol name package))
   :check-done
     ;;
     (setf (symbol-entry client name package) (values symbol new-status))
     (when (null (symbol-package client symbol))
       (setf (symbol-package client symbol) package))
   t)) ; TODO: useful return value since this is our own protocol

#++ (defmethod import ((client t) (package t) (symbol t))
  (let ((name (symbol-name client symbol))
        (new-status :internal))
    ;; Check for name conflict with present symbols.
    (multiple-value-bind (present-symbol status)
        (symbol-entry client name package)
      ;; TODO: can't we stop here if the symbol is already present?
      (unless (or (null status) (eq symbol present-symbol))
        ;; We have a conflict.
        (restart-case
            (parcl::symbol-conflict package symbol present-symbol)
          (unintern-existing-symbol ()
            (unintern client package present-symbol)
            ;; TODO(jmoringe): should we skip the other conflict check?
            )
          (do-not-import ()
            (return-from import t)))))
    ;; Check for name conflict with inherited symbols.
    (loop for used-package in (use-list client package)
          do (multiple-value-bind (inherited-symbol status)
                 (symbol-entry client name used-package)
               (cond ((not (eq status :external)))
                     ((eq symbol inherited-symbol)
                      ; (ensure-present-symbol client package symbol)
                      )
                     (t ; We have a conflict.
                      (restart-case
                          (parcl::symbol-conflict package symbol inherited-symbol)
                        (make-a-shadowing-symbol ()
                          ;; TODO: this calls import again; need something more fine-grained
                          (shadowing-import client package symbol)
                          (return-from import t)) ; TODO: useful return value since this is our own protocol
                        (do-not-import ()
                          (return-from import t)))))))
    ;;
    (setf (symbol-entry client name package) (values symbol new-status))
    (when (null (symbol-package client symbol))
      (setf (symbol-package client symbol) package))
    t))
