(cl:in-package #:parcl.middle)

(defmethod import ((client t) (package t) (symbol t))
  (prog ((name              (low:symbol-name client symbol))
         (new-export-status :internal)
         (new-shadow-status nil))
     (flet ((check-symbol (other-package other-symbol export-status shadow-status) ; TODO: containing-package
              ;; TODO(jmoringe): can't we stop checking if the symbol is already present?
              (if (eq other-symbol symbol) ; no conflict if same symbol
                  (progn
                    (setf new-export-status export-status
                          new-shadow-status shadow-status)
                    (when shadow-status
                      (go :check-done)))
                  (restart-case
                      (parcl::symbol-conflict package symbol other-symbol)
                    (unintern-existing-symbol ()
                      :test (lambda (condition)
                              (declare (ignore condition))
                              (eq other-package package))
                      (unintern client package other-symbol)
                      ;; continue checking since
                      )
                    (make-a-shadowing-symbol ()
                      :test (lambda (condition)
                              (declare (ignore condition))
                              (not (eq other-package package)))
                      (setf new-shadow-status t)
                      (go :check-done))
                    (do-not-import ()
                      (return-from import t)))))) ; TODO: different return value
       (map-accessible-entries-with-name client #'check-symbol name package))
   :check-done
     (unchecked-import client package name symbol new-export-status new-shadow-status)
   t)) ; TODO: useful return value since this is our own protocol

(defun unchecked-import (client package name symbol export-status shadow-status)
  (setf (low:symbol-entry client name package)
        (values symbol export-status shadow-status))
  (when (null (low:symbol-package client symbol))
    (setf (low:symbol-package client symbol) package)))
