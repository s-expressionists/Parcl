(cl:in-package #:parcl)

(defun %map-symbols (function package-designator)
  (let ((package (find-package package-designator)))
    (flet ((one-symbol (containing-package symbol export-status shadow-status)
             (declare (ignore containing-package export-status shadow-status))
             (funcall function symbol)))
      (parcl.middle::map-accessible-entries *client* #'one-symbol package))))

(defmacro do-symbols ((symbol-variable
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
         (%map-symbols #'body-function ,package-designator-form)
         (body-function nil t)))))
