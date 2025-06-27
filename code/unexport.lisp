(cl:in-package #:parcl)

(defun unexport (symbols &optional (package-designator *package*))
  (unless (or (symbolp symbols)
              (and (ecclesia:proper-list-p symbols)
                   (every #'symbolp symbols)))
    (error 'symbols-must-be-designator-for-list-of-symbols
           :symbols symbols))
  (let ((symbols (if (listp symbols) symbols (list symbols)))
        (package (find-package package-designator)))
    (loop for symbol in symbols
          do (parcl-low:unexport *client* package symbol))))

(setf (documentation 'unexport 'function)
      (format nil
              "Syntax: unexport symbols &optional package-designator~@
              ~@
               This function causes the symbols designated by SYMBOLS to~@
               become internal symbols of the package designated by~@
               PACKAGE-DESIGNATOR.  If PACKAGE-DESIGNATOR is not supplied,~@
               then it defaults to the current package, i.e., the value~@
               of *PACKAGE*.~@
               ~@
               A symbol in the set of symbols designated by SYMBOLS that~@
               is present in the package designated by PACKAGE-DESIGNATOR~@
               becomes internal and remains present.  If this function~@
               is given a symbol that is accessible in the package~@
               designated by PACKAGE-DESIGNATOR but that is not an~@
               external symbol, then it does nothing.~@
               ~@
               SYMBOLS is a designator for a list of symbols.~@
               In other words, if SYMBOLS is a symbol other than NIL,~@
               then that single symbol is designated.  If SYMBOLS is~@
               NIL, then no symbols are designated.  Otherwise, SYMBOLS~@
               must be a proper list of symbols in which case the elements~@
               of that list are the designated symbols.~@
               ~@
               If SYMBOLS is not a designator for a list of symbols,~@
               then an error is signaled.  If PACKAGE-DESIGNATOR is given,~@
               but it is not a package designator, then an error of type~@
               TYPE-ERROR is signaled.  If PACKAGE-DESIGNATOR is a string~@
               designator, and no package with the designated name exists,~@
               then an error of type PACKAGE-ERROR is signaled.~@
               ~@
               If any of the symbols designated by SYMBOLS is not~@
               accessible in the package designated by PACKAGE-DESIGNATOR,~@
               a correctable error of type PACKAGE-ERROR is signaled.~@
               If the package designated by PACKAGE-DESIGNATOR is either~@
               the KEYWORD package or the COMMON-LISP package, then an~@
               error of type PACKAGE-ERROR is signaled."))

; LocalWords:  designator
