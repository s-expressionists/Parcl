(cl:in-package #:parcl)

(defun symbolp (object)
  (parcl.low:symbolp *client* object))

(defun keywordp (object)
  (let ((client *client*))
    (and (parcl.low:symbolp client object)
         (eq (parcl.low:symbol-package client object)
             (parcl.low:find-package client "KEYWORD")))))

(defun symbol-name (symbol)
  ;; TODO: type check?
  (parcl.low:symbol-name *client* symbol))

(defun symbol-package (symbol)
  ;; TODO: type check?
  (parcl.low:symbol-package *client* symbol))

(defun make-symbol (name)
  (with-client-and-resolved-designators (client
                                         (name string-designator))
    (parcl.low:make-symbol client name nil)))
