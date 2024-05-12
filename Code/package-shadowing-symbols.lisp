(cl:in-package #:parcl)

(defun package-shadowing-symbols (package-designator)
  (parcl-low:shadowing-symbols *client* (find-package package-designator)))

(setf (documentation 'package-shadowing-symbols 'function)
      (format nil
              "Syntax: package-shadowing-symbols package-designator~@
               ~@
               This function returns the list symbols shadowed by~@
               package designated by PACKAGE-DESIGNATOR.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled.~@
               ~@
               The object returned by this function is part of the internal~@
               structure of the package.  The consequences are undefined~@
               if this list of destructively modified."))

; LocalWords:  designator
