(cl:in-package #:parcl)

(defun package-used-by-list (package-designator)
  (parcl-low:used-by-list *client* (find-package package-designator)))

(setf (documentation 'package-used-by-list 'function)
      (format nil
              "Syntax: package-used-by-list package-designator~@
               ~@
               This function returns the used-by list of the package~@
               designated by PACKAGE-DESIGNATOR as a list of package~@
               objects.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

; LocalWords:  designator
