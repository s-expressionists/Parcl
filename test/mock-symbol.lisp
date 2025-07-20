(cl:in-package #:parcl.test)

;;;; `mock-symbol' class

(defclass mock-symbol ()
  ((%name    :initarg  :name
             :reader   %name)
   (%package :initarg  :package
             :accessor %package
             :initform nil)))

(defmethod print-object ((object mock-symbol) stream)
  (let* ((name    (%name object))
         (package (%package object)))
    (cond ((typep package '(or null mock-package))
           (let ((package-name  (if (null package)
                                    nil
                                    (%name package)))
                 (export-status (if (null package)
                                    :uninterned
                                    (cadr (gethash name (%entries package))))))
             (format stream "~@[|~A|~]~A|~A|"
                     package-name (ecase export-status
                                    (:uninterned "#:")
                                    (:internal   "::")
                                    (:external   ":"))
                     name)))
          (t
           (print-unreadable-object (object stream :type t :identity t)
             (format stream "~S~@[ in ~A~]" name package))))))

;;;; `mock-symbol-mixin' class and methods

(defclass mock-symbol-mixin () ())

(defmethod low:symbolp ((client mock-symbol-mixin)
                        (object mock-symbol))
  t)

(defmethod low:symbol-name ((client mock-symbol-mixin)
                            (symbol mock-symbol))
  (%name symbol))

(defmethod low:symbol-package ((client mock-symbol-mixin)
                               (symbol mock-symbol))
  (%package symbol))

(defmethod (setf low:symbol-package) ((new-value t)
                                      (client    mock-symbol-mixin)
                                      (symbol    mock-symbol))
  (setf (%package symbol) new-value))

(defmethod low:make-symbol ((client  mock-symbol-mixin)
                            (name    string)
                            (package t))
  (make-instance 'mock-symbol :name name :package package))
