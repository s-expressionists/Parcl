(cl:in-package #:parcl)

(defgeneric store-package (package name nicknames))

(defun make-package (package-name &key nicknames use)
  (let ((canonicalized-name (string package-name))
        (canonicalized-nicknames (mapcar #'string nicknames))
        (canonicalized-packages
          (loop for package-to-use in use
                collect (find-package package-to-use))))
    (let ((result (parcl-low:make-package *client* canonicalized-name)))
      (setf (parcl-low:nicknames *client* result) canonicalized-nicknames)
      (parcl-low:use-packages *client* result canonicalized-packages)
      (store-package result canonicalized-name canonicalized-nicknames)
      result)))
