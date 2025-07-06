(cl:in-package #:parcl)

(defgeneric store-package (package name nicknames))

(defun make-package (package-name &key nicknames use)
  (with-client-and-resolved-designators (client
                                         (package-name string-designator)
                                         (nicknames    string-designator-list)
                                         (use          package-designator-list))
    (parcl.middle:make-package client package-name nicknames use)))

(setf (documentation 'make-package 'function)
      (format nil
              "Syntax: make-package name &key nicknames use~@
               ~@
               This function creates a new package and makes it~@
               available in the global environment so that FIND-PACKAGE~@
               can find and return it.  This function returns the new~@
               package.~@
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
