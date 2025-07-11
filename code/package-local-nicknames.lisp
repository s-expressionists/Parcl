(cl:in-package #:parcl)

(defun package-local-nicknames (package) ; TODO: designator?
  (parcl-low:local-nicknames *client* package))
