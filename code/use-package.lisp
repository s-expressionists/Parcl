(cl:in-package #:parcl)

(defun use-package (packages-to-use &optional (package-designator *package*))
  (let ((packages (if (listp packages-to-use)
                      (mapcar #'find-package packages-to-use)
                      (list (find-package packages-to-use))))
        (package (find-package package-designator)))
    (parcl-low:use-packages *client* package packages)))

(setf (documentation 'use-package 'function)
      (format nil
              "Syntax: use-package packages &optional package-designator~@
               ~@
               This function causes the packages designated by PACKAGES to~@
               be added to the use list of the package designated by~@
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
               If any of the exported symbols in any of the packages~@
               designated by PACKAGES causes a conflict with a symbol~@
               already accessible in the package designated by~@
               PACKAGE-DESIGNATOR, or with another exported symbol in~@
               any of the packages designated by PACKAGES, then a~@
               correctable error of type PACKAGE-ERROR is signaled.~@
               Such a conflict can be resolved in favor of any symbol~@
               by making it a shadowing symbol, importing it if it is~@
               one of the exported symbols in one of the packages~@
               designated by PACKAGES.
               ~@
               If PACKAGES is not a designator for a list of package~@
               designators, then an error is signaled.  If~@
               PACKAGE-DESIGNATOR is given, but it is not a package~@
               designator, then an error of type TYPE-ERROR is~@
               signaled.  If PACKAGE-DESIGNATOR is a string designator,~@
               and no package with the designated name exists, then an~@
               error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator designators
