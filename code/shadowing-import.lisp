(cl:in-package #:parcl)

(defun shadowing-import (symbols &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (symbols symbol-list-designator))
    (loop for symbol in symbols
          do (parcl.middle:shadowing-import client package symbol))))

(setf (documentation 'shadowing-import 'function)
      (format nil
              "Syntax: shadowing-import symbols &optional package-designator~@
               ~@
               This function makes symbols present as shadowing symbols~@
               in the package designated by PACKAGE-DESIGNATOR.~@
               ~@
               SYMBOLS is a designator for a list of symbols.~@
               If the optional argument is not supplied, it defaults~@
               to the current package, i.e., the value of *PACKAGE*.
               ~@
               If any of the symbols designated by SYMBOLS causes a~@
               conflict with some distinct symbol already present~@
               in the package designated by PACKAGE-DESIGNATOR, then~@
               the existing symbol is uninterned first.~@
               ~@
               If SYMBOLS is not a designator for a list of symbols,~@
               then an error is signaled. If PACKAGE-DESIGNATOR is given,~@
               but it is not a package designator, then an error of type~@
               TYPE-ERROR is signaled.  If PACKAGE-DESIGNATOR is a string~@
               designator, and no package with the designated name exists,~@
               then an error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator uninterning
