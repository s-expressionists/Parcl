(cl:in-package #:parcl.implementation.class)

;;;; `local-nicknames-mixin'

(defclass local-nicknames-mixin ()
  ((%local-nicknames      :initarg  :local-nicknames
                          :type     list ; of (cons string `package')
                          :accessor local-nicknames
                          :initform '())
   (%locally-nicknamed-by :initarg  :locally-nicknamed-by
                          :type     list ; of `package'
                          :accessor locally-nicknamed-by
                          :initform '())))

;;;; `package' class

(defclass package (parcl.low:package)
  ((%name          :initarg  #1=:name
                   :accessor name)
   (%nicknames     :initarg  :nicknames
                   :type     list ; of `string'
                   :accessor nicknames
                   :initform '())
   (%use-list      :initarg  :use-list
                   :type     list ; of `package'
                   :accessor use-list
                   :initform '())
   (%used-by-list  :initarg  :used-by-list
                   :type     list ; of `package'
                   :accessor used-by-list
                   :initform '())
   (%entries       :reader   %entries
                   :initform (make-hash-table :test #'equal))
   (%documentation :accessor documentation
                   :type     (or string null)
                   :initform nil))
  (:default-initargs
   #1# (a:required-argument #1#)))

(defmethod print-object ((object package) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~S" (name object))))

;;;; `package-with-local-nicknames' class

(defclass package-with-local-nicknames (local-nicknames-mixin package) ())
