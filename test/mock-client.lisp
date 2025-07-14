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

(defmethod clear ((client mock-environment-mixin)) ; for testing
  (clrhash (%packages client)))

;;;; `mock-client' class

(defclass mock-client (mock-symbol-mixin
                       mock-package-mixin
                       mock-environment-mixin)
  ())
