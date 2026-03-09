(cl:in-package #:parcl)

;;;

(define-condition package-system-condition (acclimation:condition)
  ()
  (:documentation
   "This condition type is a supertype of all condition types provided by
this system."))

;;; General conditions

(define-condition feature-not-supported-error (package-system-condition)
  ((%feature :initarg #1=:feature
             :reader  feature))
  (:default-initargs
   #1# (error "~@<The required initarg ~S has not been supplied.~@:>" #1#))
  (:documentation
   "This error is signaled when an attempt is made to use a non-standard
feature such as package-local nicknames which the active package
system implementation does not support."))

;;; Symbol related conditions

(define-condition symbol-name-must-be-string (type-error
                                              package-system-condition)
  ()
  (:default-initargs :expected-type 'string))

(define-condition symbols-must-be-designator-for-list-of-symbols
    (error package-system-condition)
  ((%symbols :initarg :symbols :reader symbols)))

;;; Package related conditions

;;; TODO: package-name-condition?
(define-condition package-name-occupied-condition (package-system-condition)
  ((%new-name         :initarg #1=:new-name
                      :reader  new-name)
   (%existing-package :initarg #2=:existing-package
                      :reader  existing-package))
  (:default-initargs
   #1# (error "~@<The required initarg ~S has not been supplied.~@:>" #1#)
   #2# (error "~@<The required initarg ~S has not been supplied.~@:>" #2#)))

(define-condition package-name-occupied-error (error
                                               package-name-occupied-condition)
  ()
  (:documentation
   "This error is signaled when an attempt is made to associate a,
possibly newly created, package with a name or nickname that is
already a name or nickname of a different package."))

(define-condition package-error (error package-system-condition)
  ((%package :initarg #1=:package
             :reader  package-error-package))
  (:default-initargs
   #1# (error "~@<The required initarg ~S has not been supplied.~@:>" #1#))
  (:documentation
   "This error is the supertype for errors that refer a particular package.

Direct instances of this condition type should not be signaled."))

(define-condition new-name-occupied-error (package-error
                                           package-name-occupied-condition)
  ()
  (:documentation
   "This error is signaled when an attempt is made to associate an already
existing package with a new name or new nickname that is already a
name or nickname of a different package."))

(define-condition package-does-not-exist-error (package-error)
  ()
  (:documentation
   "This error is signaled when a name that is not the name or nickname of
a package is supplied as a package designator."))

(define-condition package-has-been-deleted-error (package-error)
  ()
  (:documentation
   "This error is signaled when a deleted package object is supplied to an
operator that requires an undeleted package object."))

(define-condition package-variance-error (package-error)

  ((%aspect :initarg #1=:aspect
            :reader  aspect)
   (%event  :initarg #2=:event
            :reader  event)
   (%value  :initarg #3=:value
            :reader  value))
  (:default-initargs
   #1# (error "~@<The required initarg ~S has not been supplied.~@:>" #1#)
   #2# (error "~@<The required initarg ~S has not been supplied.~@:>" #2#)
   #3# (error "~@<The required initarg ~S has not been supplied.~@:>" #3#))
  (:documentation
   "This error is signaled when a package is updated in a way that is not
compatible with the current state of the package."))

;;; Conditions related to package-package relations

;;; Signaled from `delete-package'
(define-condition package-in-use-error (package-error)
  ((%used-by :initarg :used-by
             :reader  used-by))
  (:documentation
   "This error is signaled when an attempt is made to delete a package
that is in use by a different package."))

;;; Signaled from `add-package-local-nickname'
(define-condition nickname-refers-to-different-package-error (package-error)
  ((%nickname          :initarg :nickname
                       :reader  nickname)
   (%nicknamed-package :initarg :nicknamed-package
                       :reader  nicknamed-package))
  (:documentation
   "This error is signaled when an attempt is made to install a local
nickname in a package in which that local nickname already refers to a
different package."))

;;; Conditions related to package-symbol relations

(define-condition symbol-conflicts-error (package-error)
  (;; A list of conflicts with elements of the form
   ;;   (NAME . ((SYMBOL1 . PACKAGE1) (SYMBOL2 . PACKAGE2) ...))
   (%conflicts      :initarg  #1=:conflicts
                    :reader   conflicts)
   ;; A list of package objects and labels with elements of the form
   ;;   (PACKAGE . LABEL)
   (%package-labels :initarg  :package-labels
                    :reader   package-labels
                    :initform '()))
  (:default-initargs
   #1# (error "~@<The required initarg ~S has not been supplied.~@:>" #1#))
  (:documentation
   "This error is signaled when an operation would introduce one or more
conflicts between different symbols with the same symbol-name in a
particular package."))

(define-condition symbol-is-not-accessible-error (package-error)
  ((%inaccessible-symbol :initarg :inaccessible-symbol
                         :reader  inaccessible-symbol))
  (:documentation
   "This error is signaled when an attempt is made to export or unexport a
symbol from a package in which the symbol is not accessible."))

(define-condition unexport-forbidden-for-system-package-error (package-error)
  ((%symbol-to-unexport :initarg :symbol-to-unexport
                        :reader  symbol-to-unexport))
  (:documentation
   "This error is signaled when an attempt is made to unexport a symbol
from one of the packages COMMON-LISP and KEYWORD."))
