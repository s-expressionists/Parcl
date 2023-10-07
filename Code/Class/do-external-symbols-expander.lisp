(cl:in-package #:parcl-class)

(defmethod parcl:do-external-symbols-expander
    ((client client)
     symbol-varaible
     package-designator-form
     result-form
     body)
  (let ((package-variable (gensym)))
    (multiple-value-bind (declarations tags-and-statements)
        (separate-ordinary-body body)
      `(flet ((body-function (,symbol-variable)
                ,@declarations
                (tagbody ,tags-and-statements)))
         (let* ((,package-variable (find-package ,package)))
           (loop for entry in (symbol-entries ,package-variable)
                 when (or (eq (entry-status entry) :external)
                          (eq (entry-status entry) :external-shadowing))
                   do (body-function symbol)))
         ,result-form))))
