(cl:in-package #:parcl.test)

;;; `mock-environment-mixin' class and methods

(defclass mock-environment-mixin ()
  ((%packages :reader   %packages
              :initform (make-hash-table :test #'equal))))

(defmethod low:packages ((client mock-environment-mixin))
  (loop :for name :being :the :hash-keys :of (%packages client)
          :using (hash-value package)
        :when (equal name (low:name client package))
          :collect package :into result
        ;; `t' indicates that the returned list is freshly allocated.
        :finally (return (values result t))))

(defmethod low:find-package ((client             mock-environment-mixin)
                             (package-designator string))
  (gethash package-designator (%packages client)))

(defmethod (setf low:find-package)
    ((new-value t) (client mock-environment-mixin) (name string))
  (setf (gethash name (%packages client)) new-value))

(defmethod (setf low:find-package)
    ((new-value null) (client mock-environment-mixin) (name string))
  (remhash name (%packages client)))

(defmethod reset ((client mock-environment-mixin)) ; for testing
  (clrhash (%packages client)))

;;; `mock-client' class

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
