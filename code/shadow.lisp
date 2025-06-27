(cl:in-package #:parcl)

(defun shadow (names &optional (package-designator *package*))
  (let ((package (find-package package-designator))
        (names (if (listp names) names (list names))))
    (loop for name in names
          for string-name = (string name)
          do (parcl-low:shadow *client* package string-name))))

(setf (documentation 'shadow 'function)
      (format nil
              "Syntax: shadow symbol-names &optional package-designator~@
              ~@
               This function causes the symbols designated by SYMBOL-NAMES~@
               to be present as shadowing symbols in the package~@
               designated by PACKAGE-DESIGNATOR.  If a string in~@
               SYMBOL-NAMES does not designate a symbol that is present~@
               in the designated package, then a new symbol with that~@
               string as a name and with the designated package as its~@
               home package is created and added to the designated package~@
               as a present and shadowing symbol.  If a string in~@
               SYMBOL-NAMES does designate a symbol that is present~@
               in the designated package, then that symbol is made a~@
               shadowing symbol if that is not already the case.~@
               ~@
               If PACKAGE-DESIGNATOR is not supplied, then it defaults~@
               to the current package, i.e., the value of *PACKAGE*.~@
               ~@
               ~@
               SYMBOL-NAMES is a designator for a list of string~@
               designators. In other words, if SYMBOL-NAMES is a string~@
               designator other than the symbol NIL, then the designated~@
               string is the member of the singleton list that is~@
               designated by SYMBOL-NAMES.  If SYMBOL-NAMES is NIL, then~@
               it designates no strings.  Otherwise, SYMBOL-NAMES must~@
               be a proper list of string designators, and the list of~@
               strings designated by each such string designator is the~@
               list of strings designated by SYMBOL-NAMES.~@
               ~@
               If SYMBOLS-NAMES is not a designator for a list of string~@
               designators, then an error is signaled.  If~@
               PACKAGE-DESIGNATOR is given, but it is not a package~@
               designator, then an error of type TYPE-ERROR is signaled.~@
               If PACKAGE-DESIGNATOR is a string designator, and no~@
               package with the designated name exists, then an error~@
               of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator designators
