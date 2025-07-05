(cl:in-package #:parcl)

(defun package-nicknames (package)
  (with-client-and-resolved-designators (client
                                         (package package-designator))
    (parcl-low:nicknames client package)))

(setf (documentation 'package-nicknames 'function)
      (format nil
              "Syntax: package-nicknames package-designator~@
               ~@
               This function returns a list of the nicknames of the~@
               package designated by PACKAGE-DESIGNATOR.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

; LocalWords:  designator
