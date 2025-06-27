(cl:in-package #:parcl)

(defun package-use-list (package-designator)
  (parcl-low:use-list *client* (find-package package-designator)))

(setf (documentation 'package-use-list 'function)
      (format nil
              "Syntax: package-use-list package-designator~@
               ~@
               This function returns the use list of the package~@
               designated by PACKAGE-DESIGNATOR as a list of package~@
               objects.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

; LocalWords:  designator
