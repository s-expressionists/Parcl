(cl:in-package #:parcl)

(defun package-name (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator/weak))
    (parcl.low:name client package)))

(setf (documentation 'package-name 'function)
      (format nil
              "Syntax: package-name package-designator~@
               ~@
               This function returns the name of the package designated~@
               by PACKAGE-DESIGNATOR.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

; LocalWords:  designator
