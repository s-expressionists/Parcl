(cl:in-package #:parcl)

(defun %map-external-symbols (function package-designator)
  (let ((package (find-package package-designator)))
    (flet ((one-symbol (symbol export-status shadow-status)
             (declare (ignore shadow-status))
             (when (eq export-status :external)
               (funcall function symbol))))
      ;; TODO: pass desired status
      (parcl-low:map-symbol-entries *client* #'one-symbol package))))

(defmacro do-external-symbols ((symbol-variable
                                &optional (package-designator-form '*package*)
                                          (result-form 'nil))
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
         (%map-external-symbols #'body-function ,package-designator-form)
         (body-function nil t)))))
