(cl:in-package #:parcl.test)

;;;; `mock-environment-mixin' class and methods

(defclass mock-environment-mixin ()
  ((%packages :reader   %packages
              :initform (make-hash-table :test #'equal))))

(defmethod low:find-package ((client             mock-environment-mixin)
                             (package-designator string))
  (gethash package-designator (%packages client)))

(defmethod (setf low:find-package)
    ((new-value t) (client mock-environment-mixin) (name string))
  (setf (gethash name (%packages client)) new-value))

(defmethod reset ((client mock-environment-mixin)) ; for testing
  (clrhash (%packages client)))

;;;; `mock-client' class

(defclass mock-client (mock-symbol-mixin
                       mock-package-mixin
                       mock-environment-mixin)
  ())

;;; `mock-client-with-local-nicknames' class

(defclass mock-client-with-local-nicknames (parcl.middle::local-nicknames-mixin
                                            mock-symbol-mixin
                                            mock-package-mixin
                                            mock-environment-mixin)
  ())

(defmethod low:make-package-object ((client mock-client-with-local-nicknames)
                                    (name   string))
  (make-instance 'mock-package-with-local-nicknames :name name))

(macrolet ((define-accessor (protocol-name implementation-name)
             `(progn
                (defmethod ,protocol-name
                    ((client  mock-client-with-local-nicknames)
                     (package mock-package))
                  (,implementation-name package))

                (defmethod (setf ,protocol-name)
                    ((new-value t)
                     (client    mock-client-with-local-nicknames)
                     (package   mock-package)) ; TODO: mock-package-with-local-nicknames?
                  (setf (,implementation-name package) new-value)))))

  (define-accessor low:local-nicknames      %local-nicknames)
  (define-accessor low:locally-nicknamed-by %locally-nicknamed-by))
