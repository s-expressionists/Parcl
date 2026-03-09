(cl:in-package #:parcl)

;;;

(#+sbcl sb-ext:defglobal #-sbcl defvar **builder** 'list)

(defmacro parse (syntax form)
  `(let* ((builder       **builder**)
          (syntax        (load-time-value
                           (s-expression-syntax:find-syntax ',syntax)))
          (modified-form (list* ',syntax (rest ,form)))) ; TODO: can we avoid this?
     (handler-case
         (s-expression-syntax:parse builder syntax modified-form)
       (s-expression-syntax:s-expression-syntax-error (condition)
         ;; TODO: with-current-source-form ()
         (let ((expression (s-expression-syntax:expression condition))
               (message    (progn
                             #+TODO (s-expression-syntax:message condition)
                             (princ-to-string condition))))
           (error 'macro-syntax-error :format-control   "~S"
                                      :format-arguments (list message)
                                      :expression       expression))))))

(declaim (inline string<-designator-node value<-literal-node))

(defun string<-designator-node (designator-node)
  (let ((initargs (architecture.builder-protocol:node-initargs
                   **builder** designator-node)))
    (getf initargs :string)))

(defun value<-literal-node (literal-node)
  (let ((initargs (architecture.builder-protocol:node-initargs
                   **builder** literal-node)))
    (getf initargs :value)))

;;;

(defmacro define-macro (name (&rest lambda-list) ast-var &body body)
  (let ((cl-name              (cl:intern (string name) '#:common-lisp))
        (macro-function-name  (alexandria:symbolicate name '#:-macro-function))
        (expand-function-name (alexandria:symbolicate '#:expand- name)))
    (alexandria:with-unique-names (modified-form)
      `(progn
         (defun ,expand-function-name (,ast-var)
           ,@body)

         (defun ,macro-function-name (form)
           (,expand-function-name (parse ,cl-name form)))

         (defmacro ,name (&whole form &rest rest)
           (declare (ignore rest))
           (let ((,modified-form (list* ',cl-name (rest form)))) ; TODO: can we avoid this?
             (,macro-function-name ,modified-form)))

         #+sbcl (setf (sb-c::%fun-lambda-list (macro-function ',name))
                      ',lambda-list)))))
