(cl:in-package #:parcl)

(defun package-locally-nicknamed-by (package) ; TODO: designator?
  (parcl-low:locally-nicknamed-by *client* package))
