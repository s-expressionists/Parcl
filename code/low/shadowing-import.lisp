(cl:in-package #:parcl-low)

(defmethod shadowing-import (client package symbol)
  (let ((name (symbol-name client symbol)))
    (multiple-value-bind (present-symbol status)
        (find-present-symbol client package name)
      (unless (or (null status) (eq symbol present-symbol))
        ;; We have a conflict.  We must first unintern the conflicting
        ;; symbol.
        (unintern client package present-symbol))))
  (import client package symbol)
  ;; TODO: this does too much work since we know that the symbol is present in PACKAGE
  (shadow client package (symbol-name client symbol)))
