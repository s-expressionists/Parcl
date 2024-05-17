(cl:in-package #:parcl-low)

(defmethod shadowing-import (client package symbol)
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (let ((name (symbol-name client symbol)))
    (multiple-value-bind (present-symbol status)
        (find-present-symbol client package name)
      (unless (or (null status) (eq symbol present-symbol))
        ;; We have a conflict.  We must first unintern the conflicting
        ;; symbol.
        (unintern client package present-symbol))))
  (pushnew symbol (shadowing-symbols client package)))
