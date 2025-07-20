(cl:in-package #:parcl)

(defun unuse-package
    (packages-to-unuse &optional (package *package*))
  (with-client-and-resolved-designators
      (client
       (packages-to-unuse package-list-designator)
       (package           package-designator))
    (loop for package-to-unuse in packages-to-unuse
          do (parcl.middle:unuse-package client package package-to-unuse))
    t))

(setf (documentation 'unuse-package 'function)
      (format nil
              "Syntax: unuse-package packages &optional package-designator~@
              ~@
               This function causes the packages designated by PACKAGES to~@
               be removed from the use list of the package designated by~@
               PACKAGE-DESIGNATOR.~@
               ~@
               PACKAGES is a designator for a list of package designators.~@
               In other words, if PACKAGES is a string designator other~@
               than NIL, then a single package is designated, namely the~@
               package having the designated string as a name or nickname.~@
               If PACKAGES is NIL, then the empty list is designated.  If~@
               PACKAGES is a non-empty (proper) list, then each element~@
               is a package designator.~@
               ~@
               If PACKAGES is not a designator for a list of package~@
               designators, then an error is signaled.  If~@
               PACKAGE-DESIGNATOR is given, but it is not a package~@
               designator, then an error of type TYPE-ERROR is~@
               signaled.  If PACKAGE-DESIGNATOR is a string designator,~@
               and no package with the designated name exists, then an~@
               error of type PACKAGE-ERROR is signaled."))
