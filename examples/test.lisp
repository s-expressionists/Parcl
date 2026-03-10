#++ (ql:quickload '("computation.environment"
                "parcl-low-environment"
                    "parcl-macros"))

(cl:defpackage #:parcl.examples.environment
  (:use
   #:cl)

  (:local-nicknames
   (#:a   #:alexandria)
   (#:env #:computation.environment)))

(cl:in-package #:parcl.examples.environment)

(defclass parcl-client (parcl-low-environment:client)
  ())

;;; Simple symbol class

(defclass my-symbol ()
  ((%name    :initarg  :name
             :type     string
             :reader   %name)
   (%package :initarg  :package
             ; :type     (or null )
             :accessor %package
             :initform nil)))

(defmethod print-object ((object my-symbol) stream)
  (let ((package-name (a:when-let ((package (%package object)))
                        ;; TODO: should use the actual protocols
                        (parcl-low-environment::%name package)))
        (name         (%name object)))
   (print-unreadable-object (object stream :type t :identity t)
     (format stream "~@[~A:~]~A" package-name name))))

(defmethod parcl.low:symbol-name ((client parcl-client) (symbol my-symbol))
  (%name symbol))

(defmethod parcl.low:symbol-package ((client parcl-client) (symbol my-symbol))
  (%package symbol))

(defmethod (setf parcl.low:symbol-package) ((new-value t)
                                            (client    parcl-client)
                                            (symbol    my-symbol))
  (setf (%package symbol) new-value))

(defmethod parcl.low:make-symbol ((client parcl-client) (name t) (package t))
  (make-instance 'my-symbol :name name :package package))

;;;


(defvar *environment*
  (let ((env (make-instance 'env:global-environment)))
    (setf (env:lookup :package 'env:namespace env) (make-instance 'env::equal-namespace))
    env))

(defun test-delete-twice ()
  (let* ((parcl:*client* (make-instance 'parcl-client :environment *environment*))
         (package (parcl:make-package "some-package")))
    (parcl:shadow "1" package)
    (parcl:shadow '#:a package)
    (parcl:shadow '("3" #:b :4) package)
    (parcl:export (mapcar (lambda (name) (parcl:find-symbol name package)) '(:3 "4")) package)
    (clouseau:inspect *environment*)
    (parcl:delete-package package)
    (parcl:delete-package package)))

(defun test ()
  (let* ((parcl:*client* (make-instance 'parcl-client :environment *environment*))
         (parcl:*package* (parcl:make-package "package-foo")))
    (parcl:intern "foo")
    (parcl:find-symbol "foo")))

(defvar *environment2*
  (make-instance 'env:lexical-environment :parent *environment*))

(defun test2 ()
  (let* ((parcl:*client* (make-instance 'parcl-client :environment *environment2*))
         (parcl:*package* (parcl:find-package "package-foo")))
    (parcl:intern "bar")
    (parcl:export (parcl:find-symbol "bar"))
    ; (parcl:list-all-packages )
    (parcl:do-symbols (symbol parcl:*package*)
      (print symbol))
    (list (parcl:find-symbol "foo") (parcl:find-symbol "bar"))))

(defun test3 ()
  (let* ((parcl:*client* (make-instance 'parcl-client :environment *environment2*))
         (parcl:*package* (parcl:make-package "package-bar")))
    (parcl:use-package (parcl:find-package "package-foo"))
                                        ; (parcl:list-all-packages )
    (parcl:do-symbols (symbol parcl:*package*)
      (print symbol))
    (list (parcl:find-symbol "foo") (parcl:find-symbol "bar"))))
