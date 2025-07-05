(cl:in-package #:parcl.test)

(defclass mock-client ()
  ((%packages :reader   %packages
              :initform (make-hash-table :test #'equal))))

(defmethod low:find-package ((client mock-client) (package-designator string))
  (gethash package-designator (%packages client)))

(defmethod low:find-package ((client mock-client) (package-designator t))
  package-designator)

(defmethod (setf low:find-package)
    ((new-value t) (client mock-client) (name string))
  (setf (gethash name (%packages client)) new-value))

(defmethod clear ((client mock-client)) ; for testing
  (clrhash (%packages client)))
