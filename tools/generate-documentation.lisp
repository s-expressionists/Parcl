(cl:defpackage #:parcl.tools.generate-documentation
  (:use
   #:cl)

  (:local-nicknames
   (#:a    #:alexandria)

   (#:ti   #:parcl.tools.texinfo)))

(cl:in-package #:parcl.tools.generate-documentation)

;;; Unit descriptions and unit graph

(defun function-implementation (symbol-name)
  (multiple-value-bind (middle-name middle-status)
      (find-symbol symbol-name '#:parcl.middle)
    (multiple-value-bind (low-name low-status)
        (find-symbol symbol-name '#:parcl.low)
      (cond ((and (eq middle-status :external) (fboundp middle-name))
             (values "middle" middle-name))
            ((and (eq low-status :external) (fboundp low-name))
             (values "low" low-name))))))

(defun function-information (name)
  (let* ((function    (fdefinition name))
         (lambda-list (typecase function
                        (generic-function
                         (sb-mop:generic-function-lambda-list function))
                        (function
                         (second (function-lambda-expression function))))))
    lambda-list))

(defun emit-trampoline-function (stream info)
  (destructuring-bind (name &key (implementation (symbol-name name))
                                 include)
      (a:ensure-list info)
    (multiple-value-bind (implementation-module implementation-name)
        (function-implementation implementation)
      (let ((lambda-list (function-information name)))
        (format stream "@deffuna{~(~A~),@toppackage{}} ~{~(~A~)~^ ~}~@:_"
                name lambda-list)
        (if include
            (format stream "@include ~A~@:_~@:_~
                            @implementedby{~A,~(~A~)}~@:_"
                    include implementation-module implementation-name)
            (format stream "@trampoline{f,~(~A~),~A,~(~A~)}~@:_"
                    name implementation-module implementation-name))
        (format stream "@end deffn~@:_~@:_")))))

(defun emit-trampoline-function-group (stream group-name description names)
  (ti:write-section group-name stream)
  (ti:write-escaped description stream)
  (format stream "~@:_~@:_")
  (mapc (a:curry #'emit-trampoline-function stream) names))

(let ((stream *standard-output*))
  (pprint-logical-block (stream nil)
    (ti:write-section "High Module" stream :kind :chapter)

    (format stream "@menu~@:_~
                    ~{* ~A::~:@_~}~
                    @end menu~@:_~@:_"
            '(#100="High Conditions"
              #1="High Variables"
              #2="High Symbol Functions"
              #3="High Package Functions"
              #4="High Package-package Relation Functions"
              #5="High Package-symbol Relation Functions"
              #6="High Environment Functions"))

    (ti:write-section #100# stream)
    (do-external-symbols (symbol '#:parcl)
      (when (eq (symbol-package symbol) (find-package '#:parcl))
       (a:when-let ((class (find-class symbol nil)))
         (when (subtypep class 'condition)
           (format stream "@defclassa{~(~A~),@toppackage{}}~@:_~@:_~
                           ~A~@:_~
                           @end deftp~@:_~@:_"
                   (class-name class)
                   (documentation class t))))))

    (ti:write-section #1# stream)
    (format stream "@defvara{*client*,@toppackage{}}~@:_~
~@:_~
@cindex client parameter~@:_~
Clients set or bind this variable to an arbitrary object which ~@:_~
identifies the respective client and selects the corresponding package ~@:_~
system implementation.~@:_~
~@:_~
Functions in the high-level protocols pass the value of this variable~@:_~
to any middle- or low-level function they call.~@:_~
@end defvar~@:_~@:_")
    (format stream "@defvara{*package*,@toppackage{}}~@:_~
This variable has the same purpose as the @commonlisp{} variable
@speclinkl{v,package,*package*}~@:_~
@end defvar~@:_~@:_")

    (emit-trampoline-function-group
     stream #2#
     "The functions in this protocol involve a single symbol as either their sole argument or return values. Neither packages nor the environment are involved."
     '(parcl:symbolp
       parcl:symbol-name
       parcl:symbol-package
       parcl:make-symbol
       parcl:keywordp))

    (emit-trampoline-function-group
     stream #3#
     "The functions in this protocol involve a single package object as their only argument. Neither symbols nor the environment are involved."
     '(parcl:packagep
       (parcl:package-name :implementation "NAME")
       (parcl:package-nicknames :implementation "NICKNAMES")
       (parcl:package-local-nicknames :implementation "LOCAL-NICKNAMES"
                                      :include        "function-package-local-nicknames.texi")
       (parcl:package-locally-nicknamed-by-list :implementation "LOCALLY-NICKNAMED-BY"
                                                :include         "function-package-locally-nicknamed-by-list.texi")
       (parcl:package-use-list :implementation "USE-LIST")
       (parcl:package-used-by-list :implementation "USED-BY-LIST")
       (parcl:package-shadowing-symbols :implementation "SHADOWING-SYMBOLS")))

    (emit-trampoline-function-group
     stream #4#
     "The functions in this protocol involve multiple package objects as their arguments. Neither symbols nor the environment are involved."
     '((parcl:use-package :implementation "USE-PACKAGES")
       parcl:unuse-package
       (parcl:add-package-local-nickname :implementation "ADD-LOCAL-NICKNAME"
                                         :include        "function-add-package-local-nickname.texi")
       (parcl:remove-package-local-nickname :implementation "REMOVE-LOCAL-NICKNAME"
                                            :include        "function-remove-package-local-nickname.texi")))

    (emit-trampoline-function-group
     stream #5#
     "The functions in this protocol involve combinations of symbol objects and package objects in their arguments and return values. The environment is not involved."
     '(parcl:find-symbol
       parcl:intern
       parcl:unintern
       parcl:import
       parcl:export
       parcl:unexport
       parcl:shadow
       parcl:shadowing-import))

    (emit-trampoline-function-group
     stream #6#
     "The functions in this protocol involve the environment, mostly as a \"container\" of packages."
     '((parcl:list-all-packages :implementation "PACKAGES")
       (parcl:find-package      :implementation "FIND-PACKAGE-USING-PACKAGE")
       parcl:make-package
       parcl:delete-package
       parcl:rename-package))))
