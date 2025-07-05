(cl:in-package #:parcl-low)

(defun find-exported-symbols-in-packages (client packages name)
  (let ((result '()))
    (loop for package in packages
          do (multiple-value-bind (symbol status)
                 (symbol-entry client name package)
               (when (eq status :external)
                 (pushnew symbol result :test #'eq))))
    result))

(defmethod unintern (client package symbol)
  (let ((name (symbol-name client symbol)))
    (multiple-value-bind (present-symbol status)
        (symbol-entry client name package)
      (cond ((or (null status) (not (eq present-symbol symbol)))
             nil)
            ((member symbol (shadowing-symbols client package)) ; TODO: can't we tell from STATUS?
             (let* ((used-packages (use-list client package))
                    (symbols (find-exported-symbols-in-packages
                              client used-packages name)))
               (if (> (length symbols) 1)
                   ;; We have a conflict.  For now just signal an error.
                   (error "Symbol conflict, not uninterning ~s" symbol)
                   (progn
                     (remove-present-symbol client package symbol)
                     t))))
            (t
             (remove-present-symbol client package symbol))))))
