(cl:in-package #:parcl)

;;;

(define-condition package-system-condition (acclimation:condition)
  ())

;;; Symbol related conditions

(define-condition symbol-name-must-be-string (type-error
                                              package-system-condition)
  ()
  (:default-initargs :expected-type 'string))

(define-condition symbols-must-be-designator-for-list-of-symbols
    (error package-system-condition)
  ((%symbols :initarg :symbols :reader symbols)))

;;; Package related conditions

;;; TODO package-name-condition?
(define-condition package-name-occupied-condition (package-system-condition)
  ((%new-name         :initarg :new-name
                      :reader  new-name)
   (%existing-package :initarg :existing-package
                      :reader  existing-package)))

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
   "This error is the super-type for errors that refer a particular package.

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

;;; Conditions related to package-package relations

;;; Signaled from `delete-package'
(define-condition package-in-use-error (package-error)
  ((%used-by :initarg :used-by
             :reader  used-by))
  (:documentation
   "This error is signaled when an attempt is made to delete a package
that is in use by a different package."))

;; TODO: is this used?
(define-condition nickname-refers-to-different-package (package-error)
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
  ((%conflicts      :initarg  :conflicts
                    :reader   conflicts)
   (%package-labels :initarg  :package-labels
                    :reader   package-labels
                    :initform '())))

(define-condition symbol-is-not-accessible (package-error)
  ((%symbol :initarg :symbol
            :reader  inaccessible-symbol)))
