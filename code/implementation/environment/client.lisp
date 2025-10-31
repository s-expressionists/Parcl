(cl:in-package #:parcl.implementation.environment)

(defclass client ()
  ((%environment :initarg  #1=:environment
                 :accessor environment))
  (:default-initargs
   #1# (error "Required initarg ~S" #1#)))
