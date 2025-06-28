(cl:in-package #:parcl-low-environment)

(defclass client ()
  ((%environment :initarg  :environment
                 :accessor environment)))
