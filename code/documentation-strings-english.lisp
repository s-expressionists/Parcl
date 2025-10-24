(cl:in-package #:parcl)

;;; TODO: Missing
;;; `*package*', `*client*' and others

(setf (documentation 'delete-package 'function)
      (format nil
              "Syntax: delete-package package-designator~@
               ~@
               This function returns a generalized boolean. TODO"))

(setf (documentation 'export 'function)
      (format nil
              "Syntax: export symbols &optional package-designator~@
              ~@
               This function causes the symbols designated by SYMBOLS to~@
               become external symbols of the package designated by~@
               PACKAGE-DESIGNATOR.  If PACKAGE-DESIGNATOR is not supplied,~@
               then it defaults to the current package, i.e., the value~@
               of *PACKAGE*.~@
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
               a correctable error of type PACKAGE-ERROR is signaled,~@
               allowing the user to import the symbol first, and thereby~@
               making it accessible"))

(setf (documentation 'find-symbol 'function)
      (format nil
              "Syntax: find-symbol string &optional package-designator~@
               ~@
               This function attempts to find a symbol named STRING~@
               that is accessible in the package designated by~@
               PACKAGE-DESIGNATOR.  This function returns two values.~@
               The first value is the symbol found or NIL if no symbol~@
               named STRING is accessible in the designated package.~@
               The second value is one of the keywords :INHERITED,~@
               :EXTERNAL, or :INTERNAL, or the symbol NIL if no symbol~@
               named STRING is accessible in the designated package.~@
               ~@
               If the optional argument is not supplied, it defaults~@
               to the current package, i.e., the value of *PACKAGE*.~@
               ~@
               If STRING is not a string, then an error of type TYPE-ERROR~@
               is signaled.  If PACKAGE-DESIGNATOR is given, but it is not~@
               a package designator, then an error of type TYPE-ERROR is~@
               signaled.  If PACKAGE-DESIGNATOR is a string designator,~@
               and no package with the designated name exists, then an~@
               error of type PACKAGE-ERROR is signaled."))

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

(setf (documentation 'make-package 'function)
      (format nil
              "Syntax: make-package name &key nicknames use~@
               ~@
               This function creates a new package and makes it~@
               available in the global environment so that FIND-PACKAGE~@
               can find and return it.  This function returns the new~@
               package.~@
               ~@
               NAME is a string designator that determines the name~@
               of the new package.  NICKNAMES is a list of string~@
               designators containing the nicknames to be given to the~@
               new package.  If NICKNAMES is not supplied, it defaults~@
               to the empty list.  USE is a list of package designators~@
               where the corresponding packages will determine the initial~@
               use list of the new package.  If USE is not given, it~@
               defaults to the empty list.~@
               ~@
               If any of the packages designated by USE does not exist,~@
               then an error of type PACKAGE-ERROR is signaled.  If NAME~@
               or any of the names in NICKNAMES is the name of an existing~@
               package, then a correctable error of type PACKAGE-ERROR is~@
               signaled."))

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

(setf (documentation 'package-shadowing-symbols 'function)
      (format nil
              "Syntax: package-shadowing-symbols package-designator~@
               ~@
               This function returns the list symbols shadowed by~@
               package designated by PACKAGE-DESIGNATOR.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled.~@
               ~@
               The object returned by this function is part of the internal~@
               structure of the package.  The consequences are undefined~@
               if this list of destructively modified."))

(setf (documentation 'package-used-by-list 'function)
      (format nil
              "Syntax: package-used-by-list package-designator~@
               ~@
               This function returns the used-by list of the package~@
               designated by PACKAGE-DESIGNATOR as a list of package~@
               objects.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

(setf (documentation 'package-use-list 'function)
      (format nil
              "Syntax: package-use-list package-designator~@
               ~@
               This function returns the use list of the package~@
               designated by PACKAGE-DESIGNATOR as a list of package~@
               objects.~@
               ~@
               If PACKAGE-DESIGNATOR is not a package designator,~@
               then an error of type TYPE-ERROR is signaled.  If~@
               PACKAGE-DESIGNATOR is a string designator and no package~@
               with the designated name exists, then an error of type~@
               PACKAGE-ERROR is signaled."))

(setf (documentation 'rename-package 'function)
      (format nil
              "Syntax: rename-package TODO~@
               ~@
               TODO"))

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

(setf (documentation 'unintern 'function)
      (format nil
              "Syntax: unintern string &optional package-designator~@
               ~@
               This function returns a generalized Boolean. TODO"))

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

;;; LocalWords:  designator designators uninterning
