(cl:in-package #:parcl.middle)

;;;; Symbol functions

(defgeneric keywordp (client object))

;;;; Package functions

(defgeneric shadowing-symbols (client package))

;;;; Package-package relation functions

(defgeneric use-packages (client package packages-to-use))

(defgeneric unuse-package (client package package-to-unuse))

(defgeneric add-local-nickname (client package nickname nicknamed-package)
  (:method ((client t) (package t) (nickname t) (nicknamed-package t))
    ;; TODO: make a condition type for unsupported operations
    (error "~@<Local nicknames are not supported by this package system.~@:>")))

(defgeneric remove-local-nickname (client package nickname)
  (:method ((client t) (package t) (nickname t))
    (error "~@<Local nicknames are not supported by this package system.~@:>")))

;;;; Package-symbol relation functions

(defgeneric find-symbol (client package name))

(defgeneric intern (client package name))

(defgeneric unintern (client package symbol))

(defgeneric export (client package symbol))

(defgeneric unexport (client package symbol))

(defgeneric import (client package symbol))

(defgeneric shadow (client package name))

(defgeneric shadowing-import (client package symbol))

;;;; Environment functions

(defgeneric packages (client))

(defgeneric find-package-using-package (client package name))

(defgeneric make-package (client name nicknames used-packages))

(defgeneric delete-package (client package))

(defgeneric rename-package (client package new-name new-nicknames))

(defgeneric find-symbols (client name))

;;;; Package updating functions

(defgeneric ensure-package (client name &rest args &key &allow-other-keys))

;;; Symbol designators and package designators passed to this function
;;; have to be strings.
(defgeneric ensure-package-using-package
    (client existing-package name &rest args &key &allow-other-keys))

(defgeneric note-variance (client package aspect event value)
  (:method ((client t) (package t) (aspect t) (event t) (value t))))

(defgeneric update-package (client package &key &allow-other-keys))
