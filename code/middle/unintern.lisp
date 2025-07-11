(cl:in-package #:parcl.middle)

(defun find-exported-symbols-in-packages (client packages name)
  (let ((result '()))
    (loop for package in packages
          do (multiple-value-bind (symbol export-status)
                 (low:symbol-entry client name package)
               (when (eq export-status :external)
                 (pushnew symbol result :test #'eq))))
    result))

(defmethod unintern ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    ;; TODO: use (map-accessible-entries-with-name)
    (multiple-value-bind (present-symbol export-status)
        (low:symbol-entry client name package)
      (flet ((remove-symbol ()
               (setf (low:symbol-entry client name package) nil)
               ;; If PACKAGE is the home package of SYMBOL, reset the
               ;; home package to `nil'.
               (when (eq (low:symbol-package client symbol) package)
                 (setf (low:symbol-package client symbol) nil))))
        (cond ((or (null export-status) (not (eq present-symbol symbol)))
               nil)
              ((member symbol (shadowing-symbols client package)) ; TODO: can't we tell from STATUS?
               (let* ((used-packages (low:use-list client package))
                      (symbols       (find-exported-symbols-in-packages
                                      client used-packages name)))
                 (when (> (length symbols) 1)
                   ;; We have a conflict.  For now just signal an error.
                   (error "Symbol conflict, not uninterning ~s" symbol)))
               (remove-symbol)
               t)
              (t
               (remove-symbol)
               t))))))
