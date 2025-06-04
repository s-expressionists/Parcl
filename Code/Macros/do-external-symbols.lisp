(cl:in-package #:parcl)

(defmacro do-external-symbols
    ((symbol-variable
      &optional
        (package-designator-form '*package*)
        (result-form 'nil))
     &body body)
  (let ((package-variable (gensym)))
    (multiple-value-bind (declarations tags-and-statements)
        (ecclesia:separate-ordinary-body body)
      `(flet ((body-function (,symbol-variable)
                ,@declarations
                (tagbody ,tags-and-statements)))
         (let ((,package-variable (find-package ,package-designator-form)))
           (map-external-symbols *client* ,package-variable #'body-function))
         ,result-form))))
