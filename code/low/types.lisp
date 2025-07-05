(cl:in-package #:parcl-low)

(deftype present-symbol-status ()
  '(member :internal :internal-shadowing :external :external-shadowing))

(deftype symbol-status ()
  '(or present-symbol-status :inherited))
