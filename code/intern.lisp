(cl:in-package #:parcl)

(defun intern (name &optional (package-designator *package*))
  (parcl-low:intern *client* (find-package package-designator) name))

(setf (documentation 'intern 'function)
      (format nil
              "Syntax: intern string &optional package-designator~@
               ~@
               This function returns two values.  The first value is~@
               the symbol resulting from the operation of interning~@
               STRING.  The second value is one of the keywords~@
               :INHERITED, :EXTERNAL, or :INTERNAL, or the symbol NIL.~@
               ~@
               If the optional argument is not supplied, it defaults~@
               to the current package, i.e., the value of *PACKAGE*.
               ~@
               If a symbol with the name STRING is already accessible~@
               in the package designated by package-designator, then~@
               that symbol is returned, and the second value returned~@
               is then the status of that symbol as would be returned~@
               by a call to FIND-SYMBOL.  If no pre-existing symbol with~@
               the name STRING existed before the call, then a new~@
               symbol is created and returned as a first return value.~@
               In that case, the second return value is NIL.~@
               ~@
               STRING becomes the name of the newly created symbol.~@
               For that reason, the consequences are undefined if STRING~@
               is destructively modified after a call to this function.~@
               ~@
               If STRING is not a string, then an error of type TYPE-ERROR~@
               is signaled.  If PACKAGE-DESIGNATOR is given, but it is not~@
               a package designator, then an error of type TYPE-ERROR is~@
               signaled.  If PACKAGE-DESIGNATOR is a string designator,~@
               and no package with the designated name exists, then an~@
               error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator
