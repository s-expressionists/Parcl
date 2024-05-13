(cl:in-package #:parcl)

(defun find-symbol (name &optional (package-designator *package*))
  (unless (stringp name)
    (error 'symbol-name-must-be-string
           :datum name))
  (let ((package (find-package package-designator)))
    (parcl-low:find-symbol *client* package name)))

(setf (documentation 'find-symbol 'function)
      (format nil
              "Syntax: find-symbol string &optional package-designator~@
               ~@
               This function attempts to find a symbol named STRING~@
               that is accessible in the package designated by~@
               PACKAGE-DESIGNATOR.  This function returns two values.~@
               The first value is the symbol found or NIL if no symbol~@
               named STRING is accessible in the designated package.~@
               The second value~@ is one of the keywords :INHERITED,~@
               :EXTERNAL, or :INTERNAL, or the symbol NIL if no symbol~@
               named STRING is accessible in the designated package.~@
               ~@
               If the optional argument is not supplied, it defaults~@
               to the current package, i.e., the value of *PACKAGE*.
               ~@
               If STRING is not a string, then an error of type TYPE-ERROR~@
               is signaled.  If PACKAGE-DESIGNATOR is given, but it is not~@
               a package designator, then an error of type TYPE-ERROR is~@
               signaled.  If PACKAGE-DESIGNATOR is a string designator,~@
               and no package with the designated name exists, then an~@
               error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator
