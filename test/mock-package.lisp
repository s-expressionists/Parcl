(cl:in-package #:parcl.test)

;;; `mock-package' class

(defclass mock-package (parcl-low:package)
  ((%name          :initarg  :name
                   :accessor %name)
   (%nicknames     :accessor %nicknames
                   :initform '())
   (%uses          :accessor %uses
                   :initform '())
   (%used-by       :accessor %used-by
                   :initform '())
   (%documentation :accessor %documentation
                   :type     (or null string)
                   :initform nil)
   ;;
   (%entries       :reader   %entries
                   :initform (make-hash-table :test #'equal))))

(defmethod print-object ((object mock-package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~S" (%name object))))

;;; `mock-package-with-local-nicknames'

(defclass mock-package-with-local-nicknames (mock-package)
  ((%local-nicknames      :accessor %local-nicknames
                          :initform '())
   (%locally-nicknamed-by :accessor %locally-nicknamed-by
                          :initform '())))

;;;; `mock-package-mixin' class and methods

(defclass mock-package-mixin () ())

(defmethod low:packagep ((client mock-package-mixin) (object mock-package))
  t)

(macrolet ((define-accessor (protocol-name implementation-name)
             `(progn
                (defmethod ,protocol-name ((client  mock-package-mixin)
                                           (package mock-package))
                  (,implementation-name package))

                (defmethod (setf ,protocol-name) ((new-value t)
                                                  (client    mock-package-mixin)
                                                  (package   mock-package))
                  (setf (,implementation-name package) new-value)))))

  (define-accessor low:name          %name)
  (define-accessor low:nicknames     %nicknames)
  (define-accessor low:use-list      %uses)
  (define-accessor low:used-by-list  %used-by)
  (define-accessor low:documentation %documentation))

(defmethod low:map-symbol-entries ((client   mock-package-mixin)
                                   (function t)
                                   (package  mock-package)
                                   &optional status)
  (declare (ignore status))
  (maphash (lambda (name entry)
             (declare (ignore name))
             (destructuring-bind (symbol . (export-status . shadow-status))
                 entry
               (funcall function symbol export-status shadow-status)))
           (%entries package)))

(defmethod low:symbol-entry ((cilent  mock-package-mixin)
                             (name    string)
                             (package mock-package))
  (let ((entry (gethash name (%entries package))))
    (if (null entry)
        (values nil nil)
        (values (car entry) (cadr entry) (cddr entry)))))

(defmethod low:set-symbol-entry ((new-symbol        t)
                                 (new-export-status t)
                                 (new-shadow-status t)
                                 (client            mock-package-mixin)
                                 (name              string)
                                 (package           mock-package))
  (let ((entries (%entries package)))
    (if (null new-export-status)
        (remhash name entries)
        (setf (gethash name entries)
              (cons new-symbol (cons new-export-status new-shadow-status))))))

;;;

(defmethod low:make-package-object ((client mock-package-mixin) (name string))
  (make-instance 'mock-package :name name))
