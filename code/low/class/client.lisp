(cl:in-package #:parcl-low-class)

;;; Client code must supply a CLIENT object that is an instance of (a
;;; subclass of) this class, in order to use the methods defined in
;;; this module.
(defclass client (parcl.middle:local-nicknames-mixin) ; TODO: rename to mixin to emphasize the fact that this does not provide a complete implementation?
  ())
