(cl:in-package #:parcl-low)

(defclass package () ())

;;; TODO: maybe
(defmethod cl:documentation ((object package) (type t))
  (documentation parcl:*client* object))

(defmethod (setf cl:documentation) ((new-value t) (object package) (type t))
  (setf (documentation parcl:*client* object) new-value))
