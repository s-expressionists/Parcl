(cl:in-package #:parcl.middle)

(defmethod import ((client t) (package t) (symbol t))
  (prog ((name                  (low:symbol-name client symbol))
         (new-shadow-status     nil)
         (entry-updated?        nil)
         (home-package-changed? nil))
     (flet ((check-symbol (other-package other-symbol export-status shadow-status)
              (declare (ignore export-status shadow-status))
              (cond ((eq other-symbol symbol) ; no conflict if same symbol
                     (when (eq other-package package) ; already present
                       ;; SYMBOL is either not inherited from used
                       ;; packages or SYMBOL is shadowing in PACKAGE.
                       ;; TODO: remove later
                       (assert (eq (parcl.low:symbol-package client symbol)
                                   package))
                       (go :done)))
                    (t
                     (restart-case
                         ;; TODO: it would be good to have labels for the symbols as well
                         ;; such as SYMBOL       => "newly imported symbol"
                         ;;         OTHER-SYMBOL => "present symbol" or "inherited symbol"
                         (error 'parcl:symbol-conflicts-error
                                :package        package
                                :conflicts      `((,name . ((,symbol       . ,package)
                                                            (,other-symbol . ,other-package))))
                                :package-labels `((,package . "import target package")
                                                  ,@(unless (eq other-package package)
                                                      `((,other-package . "exporting package")))))
                       (unintern-existing-symbol ()
                         :test (lambda (condition)
                                 (declare (ignore condition))
                                 (eq other-package package))
                         (unintern client package other-symbol)
                         ;; One conflict resolved, continue checking.
                         )
                       (make-a-shadowing-symbol ()
                         :test (lambda (condition)
                                 (declare (ignore condition))
                                 (not (eq other-package package)))
                         (setf new-shadow-status t)
                         (go :update))
                       (do-not-import ()
                         (go :done)))))))
       (map-accessible-entries-with-name client #'check-symbol name package))
   :update
     (setf (low:symbol-entry client name package)
           (values symbol :internal new-shadow-status)
           entry-updated?        t
           home-package-changed? (maybe-set-home-package client package symbol))
   :done
     (values entry-updated? home-package-changed?)))

(defun unchecked-import (client package name symbol export-status shadow-status)
  (setf (low:symbol-entry client name package)
        (values symbol export-status shadow-status))
  (maybe-set-home-package client package symbol))

(defun maybe-set-home-package (client package symbol)
  (if (null (low:symbol-package client symbol))
      (progn
        (setf (low:symbol-package client symbol) package)
        t)
      nil))
