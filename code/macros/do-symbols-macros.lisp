(cl:in-package #:parcl)

(defun %map-external-symbols (function package-designator)
  (let ((package (find-package package-designator)))
    (flet ((one-symbol (symbol export-status shadow-status)
             (declare (ignore export-status shadow-status))
             (funcall function symbol)))
      (parcl.low:map-symbol-entries *client* #'one-symbol package :external))))

(defun %map-symbols (function package-designator)
  (let ((package (find-package package-designator)))
    (flet ((one-symbol (containing-package symbol export-status shadow-status)
             (declare (ignore containing-package export-status shadow-status))
             (funcall function symbol)))
      (parcl.middle::map-accessible-entries *client* #'one-symbol package))))

(defun %map-all-symbols (function)
  (let ((client *client*))
    (labels ((one-symbol (symbol export-status shadow-status)
               (declare (ignore export-status shadow-status))
               (funcall function symbol))
             (one-package (package)
               (parcl.low:map-symbol-entries client #'one-symbol package)))
      (mapc #'one-package (parcl.low:packages client)))))

(defun expand-do-*-symbols
    (mapping-function symbol-variable package-designator-form
     result-form declarations tags-and-statements)
  ;; This block and function arrangement provides a lexical binding of
  ;; SYMBOL-VARIABLE as well as the corresponding declarations for
  ;; both TAGS-AND-STATEMENTS and RESULT-FORM.
  `(block nil
     (flet ((body-function (,symbol-variable &optional donep)
              ,@declarations
              (declare (ignorable ,symbol-variable))
              (if (not donep)
                  (tagbody ,@tags-and-statements)
                  ,result-form)))
       (,mapping-function #'body-function ,@(when package-designator-form
                                              `(,package-designator-form)))
       (body-function nil t))))

;;; Macros

(defmacro do-external-symbols ((symbol-variable
                                &optional (package-designator-form '*package*)
                                          (result-form 'nil))
                               &body body)
  (multiple-value-bind (declarations tags-and-statements) (parse-body body)
    (expand-do-*-symbols
     '%map-external-symbols symbol-variable package-designator-form
     result-form declarations tags-and-statements)))

(defmacro do-symbols ((symbol-variable
                       &optional (package-designator-form '*package*)
                                 (result-form 'nil))
                      &body body)
  ;; TODO: test
  (multiple-value-bind (declarations tags-and-statements) (parse-body body)
    (expand-do-*-symbols
     '%map-symbols symbol-variable package-designator-form
     result-form declarations tags-and-statements)))

(defmacro do-all-symbols ((symbol-variable &optional (result-form 'nil))
                          &body body)
  (multiple-value-bind (declarations tags-and-statements) (parse-body body)
    (expand-do-*-symbols
     '%map-all-symbols symbol-variable nil
     result-form declarations tags-and-statements)))
