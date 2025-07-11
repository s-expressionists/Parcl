(cl:in-package #:parcl-low)

(deftype symbol-export-status ()
  '(member nil :internal :external))

;;; TODO: symbol-presence-status or similar
(deftype present-symbol-status ()
  '(member :internal :internal-shadowing :external :external-shadowing))

(defun symbol-presence-status (export-status shadow-status)
  (ecase export-status
    (:internal (if shadow-status
                   :internal
                   :internal-shadowing))
    (:external (if shadow-status
                   :external
                   :external-shadowing))))

(deftype symbol-status ()
  '(or present-symbol-status :inherited))
