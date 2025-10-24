(cl:in-package #:parcl-low-class)

(defclass package (parcl.low:package)
  ((%name                 :initarg  #1=:name
                          :accessor name)
   (%nicknames            :initarg  :nicknames
                          :type     list ; of string
                          :accessor nicknames
                          :initform '())
   (%local-nicknames      :initarg  :local-nicknames
                          :type     list ; of TODO
                          :accessor local-nicknames
                          :initform '())
   (%locally-nicknamed-by :initarg  :locally-nicknamed-by
                          :type     list ; of TODO
                          :accessor locally-nicknamed-by
                          :initform '())
   (%use-list             :initarg  :use-list
                          :type     list ; of (satisfies packagep)
                          :accessor use-list
                          :initform '())
   (%used-by-list         :initarg  :used-by-list
                          :type     list ; of (satisfies packagep)
                          :accessor used-by-list
                          :initform '())
   (%entries              :reader   %entries
                          :initform (make-hash-table :test #'equal)))
  (:default-initargs
   ;: TODO: make a helper function or use alexandria
   #1# (error "The initarg ~S is required by class ~S" '#1# 'package)))

(defmethod print-object ((object package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~S" (name object))))
