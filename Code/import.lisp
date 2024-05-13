(cl:in-package #:parcl)

(defun import (symbols &optional (package-designator *package*))
  (unless (or (symbolp symbols)
              (and (ecclesia:proper-list-p symbols)
                   (every #'symbolp symbols)))
    (error 'symbols-must-be-designator-for-list-of-symbols
           :symbols symbols))
  (let ((symbols (if (listp symbols) symbols (list symbols)))
        (package (find-package package-designator)))
    (loop for symbol in symbols
          do (parcl-low:import *client* package symbol))))

(setf (documentation 'import 'function)
      (format nil
              "Syntax: import symbols &optional package-designator~@
               ~@
               This function makes symbols present in the package~@
               designated by PACKAGE-DESIGNATOR.~@
               ~@
               SYMBOLS is a designator for a list of symbols.~@
               If the optional argument is not supplied, it defaults~@
               to the current package, i.e., the value of *PACKAGE*.
               ~@
               If any of the symbols designated by SYMBOLS causes a~@
               conflict with some distinct symbol already accessible~@
               in the package designated by PACKAGE-DESIGNATOR, then~@
               a correctable error of type PACKAGE-ERROR is signaled.~@
               ~@
               If any of the symbols designated by SYMBOLS causes a~@
               conflict with a symbol inherited from one of the~@
               packages used by the designated package, then the conflict~@
               can be resolved either in favor of the symbol being~@
               imported by making it a shadowing symbol, or in favor~@
               of the existing accessible symbol by not doing the import.@
               ~@
               If any of the symbols designated by SYMBOLS causes a~@
               conflict with a symbol already present in the designated~@
               package, then the conflict can be resolved in favor of~@
               the imported symbol uninterning the existing symbol, or~@
               in favor of the existing symbol by not doing the import.~@
               ~@
               If SYMBOLS is not a designator for a list of symbols,~@
               then an error is signaled. If PACKAGE-DESIGNATOR is given,~@
               but it is not a package designator, then an error of type~@
               TYPE-ERROR is signaled.  If PACKAGE-DESIGNATOR is a string~@
               designator, and no package with the designated name exists,~@
               then an error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator uninterning
