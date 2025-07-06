(cl:in-package #:parcl.middle)

(defun find-exported-symbols-in-packages (client packages name)
  (let ((result '()))
    (loop for package in packages
          do (multiple-value-bind (symbol status)
                 (low:symbol-entry client name package)
               (when (eq status :external)
                 (pushnew symbol result :test #'eq))))
    result))

(defmethod unintern (client package symbol)
  (let ((name (low:symbol-name client symbol)))
    ;; TODO: use (map-accessible-entries-with-name)
    (multiple-value-bind (present-symbol status)
        (low:symbol-entry client name package)
      (cond ((or (null status) (not (eq present-symbol symbol)))
             nil)
            ((member symbol (shadowing-symbols client package)) ; TODO: can't we tell from STATUS?
             (let* ((used-packages (low:use-list client package))
                    (symbols (find-exported-symbols-in-packages
                              client used-packages name)))
               (if (> (length symbols) 1)
                   ;; We have a conflict.  For now just signal an error.
                   (error "Symbol conflict, not uninterning ~s" symbol)
                   (progn
                     (setf (low:symbol-entry client name package) nil)
                     t))))
            (t
             (setf (low:symbol-entry client name package) nil))))))
