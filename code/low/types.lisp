(cl:in-package #:parcl-low)

(deftype symbol-export-status ()
  '(member nil :internal :external)) ; TODO: maybe without nil?

(deftype symbol-access-status ()
  '(or symbol-export-status (eql :inherited)))

(deftype symbol-shadow-status ()
  'boolean)
