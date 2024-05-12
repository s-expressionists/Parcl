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

(setf (documentation 'make-package 'function)
      (format nil
              "Syntax: make-package name &key nicknames use~@
               ~@
               This function creates a new package and makes it~@
               available in the global environment so that FIND-PACKAGE~@
               can find and return it.~@
               ~@
               NAME is a string designator that determines the name~@
               of the new package.  NICKNAMES is a list of string~@
               designators containing the nicknames to be given to the~@
               new package.  If NICKNAMES is not supplied, it defaults~@
               to the empty list.  USE is a list of package designators~@
               where the corresponding packages will determine the initial~@
               use list of the new package.  If USE is not given, it~@
               defaults to the empty list.~@
               ~@
               If any of the packages designated by USE does not exist,~@
               then an error of type PACKAGE-ERROR is signaled.  If NAME~@
               or any of the names in NICKNAMES is the name of an existing~@
               package, then a correctable error of type PACKAGE-ERROR is~@
               signaled."))

; LocalWords:  designator designators
