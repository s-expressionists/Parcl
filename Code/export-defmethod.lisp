(cl:in-package #:parcl)

(defun resolve-conflict (symbols package)
  (restart-case (error 'symbol-conflict
                       :conflicting-symbols symbols
                       :package package)
    (choose-a-symbol ()
      :report
      (lambda (stream)
        (format stream "Choose a symbol"))
      :interactive
      (lambda ()
        (format *debug-io* "Your choice: ")
        (return-from resolve-conflict
          (read *debug-io*))))))

(defmethod export (client package symbol)
  nil)