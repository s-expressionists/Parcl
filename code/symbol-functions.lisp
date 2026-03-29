(cl:in-package #:parcl)

(defun symbolp (object)
  (parcl.low:symbolp *client* object))

(defun symbol-name (symbol)
  ;; TODO: type check?
  (parcl.low:symbol-name *client* symbol))

(defun symbol-package (symbol)
  ;; TODO: type check?
  (parcl.low:symbol-package *client* symbol))

(defun make-symbol (name)
  (with-resolved-designators (client (name string-designator))
    (parcl.low:make-symbol client name nil)))

(defun keywordp (object)
  (parcl.middle:keywordp *client* object))
