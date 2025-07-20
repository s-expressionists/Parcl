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
  ())

(define-condition package-error (error package-system-condition)
  ((%package :initarg #1=:package
             :reader  package-error-package))
  (:default-initargs
   #1# (error "Required argument ~s" #1#)))

(define-condition new-name-occupied-error (package-error
                                           package-name-occupied-condition)
  ())

(define-condition package-does-not-exist-error (package-error)
  ())

(define-condition package-has-been-deleted-error (package-error)
  ())

;;; Conditions related to package-package relations

;; signaled from `delete-package'
(define-condition package-in-use-error (package-error)
  ((%used-by :initarg :used-by
             :reader  used-by)))

;;; This condition is signaled by UNUSE-PACKAGE when the package is
;;; not used, so that it can't be unused.
(define-condition package-is-not-used (package-error) ; TODO: is this used?
  ((%package-to-unuse :initarg :package-to-unuse
                      :reader  package-to-unuse)))

;; TODO: is this used?
(define-condition nickname-refers-to-different-package (package-error)
  ((%nickname          :initarg :nickname
                       :reader  nickname)
   (%nicknamed-package :initarg :nicknamed-package
                       :reader  nicknamed-package)))

;;; Conditions related to package-symbol relations

;;; TODO: delete one of the two
(define-condition symbol-conflict (package-error)
  ((%conflicting-symbols :initarg :conflicting-symbols
                         :reader  conflicting-symbols)))

(defun symbol-conflict (package &rest conflicting-symbols)
  (error 'symbol-conflict :package             package
                          :conflicting-symbols conflicting-symbols))

(define-condition symbol-conflicts-error (package-error)
  ((%conflicts      :initarg  :conflicts
                    :reader   conflicts)
   (%package-labels :initarg  :package-labels
                    :reader   package-labels
                    :initform '())))

(define-condition symbol-is-not-accessible (package-error)
  ((%symbol :initarg :symbol
            :reader  inaccessible-symbol)))
