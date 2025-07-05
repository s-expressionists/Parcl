(cl:in-package #:parcl.test)

(defclass mock-symbol ()
  ((%name    :initarg  :name
             :reader   %name)
   (%package :initarg  :package
             :accessor %package
             :initform nil)))

(defmethod print-object ((object mock-symbol) stream)
  (let* ((name         (%name object))
         (package      (%package object))
         (package-name (if (null package)
                           nil
                           (%name package)))
         (status       (if (null package)
                           :uninterned
                           (cdr (gethash name (%entries package))))))
    (format stream "~@[|~A|~]~A|~A|"
            package-name
            (ecase status
              (:uninterned                     "#:")
              ((:internal :internal-shadowing) "::")
              ((:external :external-shadowing) ":"))
            name))
  #+no (print-unreadable-object (object stream :type t :identity t)
         (format stream "~S" (%name object))))

(defmethod low:symbolp ((client mock-client) (object mock-symbol))
  t)

(defmethod low:symbol-name ((client mock-client) (symbol mock-symbol))
  (%name symbol))

(defmethod low:symbol-package ((client mock-client) (symbol mock-symbol))
  (%package symbol))

(defmethod (setf low:symbol-package) ((new-value t)
                                      (client    mock-client)
                                      (symbol    mock-symbol))
  (setf (%package symbol) new-value))

(defmethod low:make-symbol ((client mock-client) (name string) (package t))
  (make-instance 'mock-symbol :name name :package package))
