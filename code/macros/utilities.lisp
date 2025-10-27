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
         (let ((message (progn
                          #+TODO (s-expression-syntax:message condition)
                          (princ-to-string condition))))
           (error 'macro-syntax-error :format-control   "~S"
                                      :format-arguments (list message)))))))

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
  (let ((cl-name (cl:intern (string name) '#:common-lisp)))
    `(progn
       (defmacro ,name (&whole form &rest rest)
         (declare (ignore rest))
         (let ((,ast-var (parse ,cl-name form)))
           ,@body))
       #+sbcl (setf (sb-c::%fun-lambda-list (macro-function ',name))
                    ',lambda-list))))
