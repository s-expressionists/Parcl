(cl:in-package #:parcl)

(defun find-symbol (name &optional (package-designator *package*))
  (unless (stringp name)
    (error 'symbol-name-must-be-string
           :datum name))
  (let ((package (find-package package-designator)))
    (parcl-low:find-symbol *client* package name)))
