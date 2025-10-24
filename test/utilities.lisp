(cl:in-package #:parcl.test)

;;; Predicates

(defun set-equal (left right &key (test #'eql))
  (and (= (length left) (length right))
       (a:set-equal left right :test test)))

(defun set-equal/equal (left right)
  (set-equal left right :test #'equal))

;;; Fixtures

(defgeneric setup (client)
  (:method ((client t))))

(defgeneric reset (client)
  (:method ((client t))))

(defun call-with-fresh-package-system (continuation)
  (let ((client parcl:*client*))
    (setup client)
    (unwind-protect
         (funcall continuation)
      (reset client))))

(defmacro with-fresh-package-system (() &body body)
  `(call-with-fresh-package-system (lambda () ,@body)))

(defvar *client-maker*
  (lambda () (make-instance 'mock-client)))

(defun call-with-mock-package-system (continuation)
  (let* ((client (funcall *client-maker*))
         (parcl:*client* client))
    (with-fresh-package-system ()
      (funcall continuation client))))

(defmacro with-mock-package-system
    ((&optional (client-var (gensym "CLIENT") client-var-supplied-p))
     &body body)
  `(call-with-mock-package-system
    (lambda (,client-var)
      ,@(unless client-var-supplied-p `((declare (ignore ,client-var))))
      ,@body)))

(defun call-with-mock-package (continuation name)
  (let ((package (parcl:make-package name)))
    (funcall continuation package)))

(defmacro with-mock-package ((package-var name) &body body)
  (multiple-value-bind (package-var ignorep)
      (if (null package-var)
          (values (gensym "PACKAGE-VAR") t)
          (values package-var            nil))
    `(call-with-mock-package
      (lambda (,package-var)
        ,@(when ignorep `((declare (ignore ,package-var))))
        ,@body)
      ,name)))

(defmacro with-mock-package-constellation ((&rest bindings) &body body)
  (labels ((binding (remaining)
             (destructuring-bind (&optional first &rest rest) remaining
               (if (null first)
                   `(progn ,@body)
                   `(with-mock-package (,@first)
                      ,(binding rest))))))
   `(with-mock-package-system ()
      ,(binding bindings))))

;;;

(defmacro do-string-designators ((variable string) &body body)
  (let ((do-it (gensym "DO-IT")))
    `(flet ((,do-it (,variable) ,@body))
       (,do-it ,string)
       (,do-it (parcl:make-symbol ,string)))))

(defmacro do-string-list-designators ((variable string) &body body)
  (let ((do-it (gensym "DO-IT")))
    `(do-string-designators (,variable ,string)
       (flet ((,do-it (,variable) ,@body))
         (,do-it ,variable)
         (,do-it (list ,variable))))))
