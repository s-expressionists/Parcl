(cl:in-package #:parcl-class)

(defmethod parcl:do-symbols-expander
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
         (let* ((,package-variable (find-package ,package))
                (visited 
                  (loop for entry in (symbol-entries ,package-variable)
                        for symbol = (entry-symbol entry)
                        do (body-function symbol)
                        collect symbol)))
           (loop for package in (use-list ,package-variable)
                 do (do-external-symbols (symbol package)
                      (unless (member symbol visited
                                      :test (lambda (symbol1 symbol2)
                                              (parcl:symbol-names-equal
                                               *client* symbol1 symbol2)))
                        (body-function symbol)
                        (push symbol visited)))))
         ,result-form))))
