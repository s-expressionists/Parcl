(cl:in-package #:parcl-low)

;;; This function can be used to implement the standard function
;;; FIND-SYMBOL.  Just like the standard function, it returns two
;;; values.  The first value is either a symbol with the name NAME
;;; accessible in PACKAGE, or NIL if there is no such symbol.  The
;;; second value is either :INTERNAL, :EXTERNAL, :INHERITED, or NIL.
(defgeneric find-symbol (client package name))

(defmethod find-symbol (client package name)
  (multiple-value-bind (symbol status)
      (find-present-symbol client package name)
    (if (not (null status))
        (values symbol status)
        (loop for used-package in (use-list client package)
              do (multiple-value-bind (symbol status)
                     (find-present-symbol client used-package name)
                   (unless (null status)
                     (return (values symbol :inherited))))
              finally (return (values nil nil))))))
