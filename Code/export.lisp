(cl:in-package #:parcl)

(defun export (symbols &optional (package-designator *package*))
  (unless (or (symbolp symbols)
              (and (ecclesia:proper-list-p symbols)
                   (every #'symbolp symbols)))
    (error 'symbols-must-be-designator-for-list-of-symbols
           :symbols symbols))
  (let ((symbols (if (listp symbols) symbols (list symbols)))
        (package (find-package package-designator)))
    (loop for symbol in symbols
          do (parcl-low:export *client* package symbol))))
