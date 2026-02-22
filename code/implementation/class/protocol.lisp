(cl:in-package #:parcl.implementation.class)

(defgeneric name (package))

(defgeneric (setf name) (new-name package))

(defgeneric nicknames (package))

(defgeneric (setf nicknames) (new-nicknames package))

;;; Return a list of pairs of the form (<name> . <package>) where
;;; <name> is a string representing a package-local nickname and
;;; <package> is a package object with that nickname.
(defgeneric local-nicknames (package))

(defgeneric (setf local-nicknames) (new-local-nicknames package))

;;; Return a list of packages that have package-local nicknames for
;;; this package.
(defgeneric locally-nicknamed-by (package))

(defgeneric (setf locally-nicknamed-by) (packages package))

(defgeneric use-list (package))

(defgeneric (setf use-list) (new-use-list package))

(defgeneric used-by-list (package))

(defgeneric (setf used-by-list) (new-used-by-list package))

(defgeneric documentation (package))

(defgeneric (setf documentation) (new-value package))
