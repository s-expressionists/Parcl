(cl:in-package #:parcl)

(defmethod cl:documentation ((object parcl.low:package) (doc-type t))
  (parcl.low:documentation parcl:*client* object))

(defmethod (setf cl:documentation)
    ((new-value t) (object parcl.low:package) (doc-type t))
  (setf (parcl.low:documentation parcl:*client* object) new-value))
