(cl:in-package #:parcl.implementation.class)

;;;; `package-class-mixin' class

;;; Client code must supply a CLIENT object that is an instance of (a
;;; subclass of) this class, in order to use the methods defined in
;;; this module.
(defclass package-class-mixin ()
  ())

;;;; `client' class

(defclass client (package-class-mixin) ())

;;;; `client-with-local-nicknames' class

(defclass client-with-local-nicknames
    (parcl.middle:local-nicknames-mixin client)
  ())
