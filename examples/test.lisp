#++ (ql:quickload '("computation.environment"
                "parcl-low-environment"))

(cl:defpackage #:parcl.examples.environment
  (:use
   #:cl)

  (:local-nicknames
   (#:env #:computation.environment)))

(cl:in-package #:parcl.examples.environment)

(defclass parcl-client (parcl-low-environment:client)
  ())

;;; Simple symbol class

(defclass my-symbol ()
  ((%name    :initarg  :name
             :reader   %name)
   (%package :initarg  :package
             :reader   %package
             :initform nil)))

(defmethod print-object ((object my-symbol) stream)
  (let ((package-name (alexandria:when-let ((package (%package object)))
                        ;; TODO: should use the actual protocols
                        (parcl-low-environment::%name package)))
        (name         (%name object)))
   (print-unreadable-object (object stream :type t :identity t)
     (format stream "~@[~A:~]~A" package-name name))))

(defmethod parcl-low:make-symbol ((client parcl-client) (name t) (package t))
  (make-instance 'my-symbol :name name :package package))

(defmethod parcl-low:symbol-name ((client parcl-client) (symbol my-symbol))
  (%name symbol))

(defmethod parcl-low:symbol-package ((client parcl-client) (symbol my-symbol))
  (%package symbol))

;;;


(defvar *environment*
  (let ((env (make-instance 'env:global-environment)))
    (setf (env:lookup :package 'env:namespace env) (make-instance 'env::equal-namespace))
    env))

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
