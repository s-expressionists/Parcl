(cl:in-package #:parcl.low)

;;;; Symbol functions

(defgeneric symbolp (client object)
    ;; Default behavior
  (:method ((client t) (object t))
    nil))

(defgeneric symbol-name (client symbol))

(defgeneric symbol-package (client symbol))

(defgeneric (setf symbol-package) (new-value client symbol))

(defgeneric make-symbol (client name package))

;;;; Package functions

(defgeneric packagep (client object)
  ;; Default behavior
  (:method ((client t) (object t))
    nil))

(defgeneric name (client package))

(defgeneric (setf name) (new-value client package))

(defgeneric nicknames (client package))

(defgeneric (setf nicknames) (new-value client package))

(defgeneric local-nicknames (client package)
  (:method ((client t) (package t))
    (error "~@<Local nicknames are not supported by this package system.~@:>")))

(defgeneric (setf local-nicknames) (new-value client package))

(defgeneric locally-nicknamed-by (client package)
  (:method ((client t) (package t))
    (error "~@<Local nicknames are not supported by this package system.~@:>")))

(defgeneric (setf locally-nicknamed-by) (new-value client package))

(defgeneric use-list (client package))

(defgeneric (setf use-list) (new-packages client package))

(defgeneric used-by-list (client package))

(defgeneric (setf used-by-list) (new-packages client package))

(defgeneric documentation (client package))

(defgeneric (setf documentation) (new-value client package))

(defgeneric make-package-object (client name))

;;;; Package-symbol relation functions

(defgeneric map-symbol-entries (client function package &optional status))

(defgeneric symbol-entry (client name package))

(defgeneric set-symbol-entry
    (symbol export-status shadow-status client name package))

(defsetf symbol-entry (client name package) (symbol export-status shadow-status)
  `(set-symbol-entry
     ,symbol ,export-status ,shadow-status ,client ,name ,package))

;;;; Environment functions

(defgeneric packages (client))

(defgeneric find-package (client name))

(defgeneric (setf find-package) (new-value client name))

;;;; TODO

;;; This function is used by the macro DO-SYMBOLS to compute the
;;; expansion.
(defgeneric do-symbols-expander
    (client symbol-variable package-designator-form result-form body))

;;; This function is used by the macro DO-EXTERNAL-SYMBOLS to compute
;;; the expansion.
(defgeneric do-external-symbols-expander
    (client symbol-variable package-designator-form result-form body))
