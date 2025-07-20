(cl:in-package #:parcl)

(defun parse (form &key replace-operator)
  (let* ((builder       (make-instance 'iconoclast-builder:builder))
         (modified-form (list* replace-operator (rest form)))) ; TODO: can we avoid this?
    (handler-case
        (s-expression-syntax:parse builder t modified-form)
      (s-expression-syntax:s-expression-syntax-error (condition)
        ;; TODO: with-current-source-form ()
        (let ((message (s-expression-syntax:message condition)))
          (error 'macro-syntax-error
                 :format-control   "~S"
                 :format-arguments (list message)))))))
