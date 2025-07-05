(cl:in-package #:parcl.test)

(defclass mock-package ()
  ((%name                 :initarg  :name
                          :accessor %name)
   (%nicknames            :accessor %nicknames
                          :initform '())
   (%local-nicknames      :accessor %local-nicknames
                          :initform '())
   (%locally-nicknamed-by :accessor %locally-nicknamed-by
                          :initform '())
   (%uses                 :accessor %uses
                          :initform '())
   (%used-by              :accessor %used-by
                          :initform '())
   (%entries              :reader   %entries
                          :initform (make-hash-table :test #'equal))))

(defmethod print-object ((object mock-package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~S" (%name object))))

(defmethod low:packagep ((client mock-client) (object mock-package))
  t)

(macrolet ((define-accessor (protocol-name implementation-name)
             `(progn
                (defmethod ,protocol-name ((client  mock-client)
                                           (package mock-package))
                  (,implementation-name package))

                (defmethod (setf ,protocol-name) ((new-value t)
                                                  (client    mock-client)
                                                  (package   mock-package))
                  (setf (,implementation-name package) new-value)))))

  (define-accessor low:name                 %name)
  (define-accessor low:nicknames            %nicknames)
  (define-accessor low:local-nicknames      %local-nicknames)
  (define-accessor low:locally-nicknamed-by %locally-nicknamed-by)
  (define-accessor low:use-list             %uses)
  (define-accessor low:used-by-list         %used-by))

(defmethod low::map-symbol-entries ((client   mock-client)
                                    (function t)
                                    (package  mock-package)
                                    &optional status)
  (maphash (lambda (name entry)
             (declare (ignore name))
             (destructuring-bind (symbol . status) entry
               (funcall function symbol status)))
           (%entries package)))

(defmethod low::symbol-entry ((cilent  mock-client)
                              (name    string)
                              (package mock-package))
  (let ((entry (gethash name (%entries package))))
    (if (null entry)
        (values nil nil)
        (values (car entry) (cdr entry)))))

(defmethod low::set-symbol-entry ((new-symbol t)
                                  (new-status t)
                                  (client     mock-client)
                                  (name       string)
                                  (package    mock-package))
  (setf (gethash name (%entries package)) (cons new-symbol new-status)))

;;;

(defmethod low::make-package-object ((client mock-client) (name string))
  (make-instance 'mock-package :name name))
