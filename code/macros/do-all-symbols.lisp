(cl:in-package #:parcl)

(defun %map-all-symbols (function)
  (let ((client *client*))
    (labels ((one-symbol (symbol export-status shadow-status)
               (declare (ignore export-status shadow-status))
               (funcall function symbol))
             (one-package (package)
               (parcl-low:map-symbol-entries client #'one-symbol package)))
      (mapc #'one-package (parcl-low:packages client)))))

(defmacro do-all-symbols ((symbol-variable &optional (result-form 'nil))
                          &body body)
  (multiple-value-bind (declarations tags-and-statements)
      (ecclesia:separate-ordinary-body body)
    `(block nil
       (flet ((body-function (,symbol-variable &optional donep)
                ,@declarations
                (declare (ignorable ,symbol-variable))
                (if (not donep)
                    (tagbody ,@tags-and-statements)
                    (return ,result-form))))
         (%map-all-symbols #'body-function)
         (body-function nil t)))))
