(cl:in-package #:parcl.middle)

;;; This function detects and resolves a conflict between SYMBOL and a
;;; present symbol S in USING-PACKAGE where USING-PACKAGE uses
;;; PACKAGE.  The standard says that such a conflict can be resolved
;;; in favor of SYMBOL by uninterning S in USING-PACKAGE, or by making
;;; S a shadowing symbol in USING-PACKAGE.
(defun detect-and-resolve-export-conflict-1 (client symbol using-package)
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (conflicting-symbol export-status shadow-status)
        (low:symbol-entry client name using-package)
      (when (and (not (null export-status)) (not shadow-status))
        (restart-case
            (parcl::symbol-conflict using-package symbol conflicting-symbol)
          (unintern ()
            :report (lambda (stream)
                      (parcl::report-restart
                       'unintern stream conflicting-symbol using-package))
            (return-from detect-and-resolve-export-conflict-1
              (lambda ()
                (unintern client using-package symbol))))
          (shadow ()
            :report (lambda (stream)
                      (parcl::report-restart
                       'shadow  stream conflicting-symbol using-package))
            (return-from detect-and-resolve-export-conflict-1
              (lambda ()
                (setf (low:symbol-entry client name using-package)
                      (values conflicting-symbol export-status t)))))
          (do-not-export ()
            :report (lambda (stream)
                      (parcl::report-restart 'do-not-export stream symbol stream))
            (return-from detect-and-resolve-export-conflict-1
              :abort))))))
  ;; Return NIL to indicate that there was no conflict
  nil)

;;; This function detects and resolves a conflict between SYMBOL and
;;; an external symbol in some package P that is used by
;;; USING-PACKAGE.  The standard does not mention what possible ways
;;; such a conflict can be resolved, but we think that either symbol
;;; can be imported into USING-PACKAGE as a shadowing symbol.
(defun detect-and-resolve-export-conflict-2/unshadowed
    (client package symbol using-package)
  ;; TODO: can't we use one of the map- functions?
  (loop named nil
        with name = (low:symbol-name client symbol)
        for used-package in (low:use-list client using-package)
        unless (eq used-package package)
          do (multiple-value-bind (conflicting-symbol export-status)
                 (low:symbol-entry client name used-package)
               (when (and (eq export-status :external)
                          (not (eq symbol conflicting-symbol)))
                 (restart-case
                     (parcl::symbol-conflict
                      using-package symbol conflicting-symbol)
                   (make-old-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart 'make-old-shadowing
                                                      stream
                                                      conflicting-symbol
                                                      using-package))
                     (return
                       (lambda ()
                         (setf (low:symbol-entry client name using-package)
                               (values conflicting-symbol export-status t)))))
                   (make-new-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                'make-new-shadowing stream symbol using-package))
                     (return
                       (lambda ()
                         (setf (low:symbol-entry client name using-package)
                               (values symbol :external t))))) ; TODO: not sure about the export-status
                   (do-not-export ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                'do-not-export stream symbol))
                     (return :abort)))))
        finally (return nil))) ; Return `nil' to indicate that there was no conflict

(defun detect-and-resolve-export-conflict-2
    (client package symbol using-package)
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (present-symbol export-status shadow-status)
        (low:symbol-entry client name using-package)
      (declare (ignore present-symbol export-status))
      (if shadow-status
          nil      ; Return NIL to indicate that there was no conflict
          (detect-and-resolve-export-conflict-2/unshadowed
           client package symbol using-package)))))

;;; This function handles the case where SYMBOL is not accessible in
;;; PACKAGE
(defun detect-and-resolve-export-non-accessibility (client package symbol)
  (map-accessible-entries-with-name
   client
   (lambda (containing-package other-symbol export-status shadow-status)
     (declare (ignore containing-package other-symbol export-status shadow-status))
     (return-from detect-and-resolve-export-non-accessibility nil))
   (low:symbol-name client symbol) package)
  (restart-case (error 'parcl::symbol-is-not-accessible
                       :package package
                       :symbol symbol)
    (import ()
      :report (lambda (stream)
                (parcl::report-restart 'import stream symbol package))
      (lambda ()
        (import client package symbol)))
    (do-not-export ()
      :report (lambda (stream)
                (parcl::report-restart 'do-not-export stream symbol))
      :abort)))

(defmethod export ((client t) (package t) (symbol t))
  (let ((action-1 (detect-and-resolve-export-non-accessibility
                   client package symbol)))
    (unless (eq action-1 :abort)
      (let ((action-2
              (loop for using-package in (low:used-by-list client package)
                      thereis (detect-and-resolve-export-conflict-1
                               client symbol using-package))))
        (unless (eq action-2 :abort)
          (let ((action-3
                  (loop for using-package in (low:used-by-list client package)
                          thereis (detect-and-resolve-export-conflict-2
                                   client package symbol using-package))))
            (unless (eq action-3 :abort)
              (unless (null action-1) (funcall action-1))
              (unless (null action-2) (funcall action-2))
              (unless (null action-3) (funcall action-3))
              (when (and (null action-1) (null action-2) (null action-3))
                (let ((name (low:symbol-name client symbol)))
                  (multiple-value-bind (old-symbol old-export-status old-shadow-status)
                      (low:symbol-entry client name package) ; TODO: action-1 should have done this lookup
                    (declare (ignore old-symbol))
                    ;; Change export-status to `:external' if SYMBOL
                    ;; was inherited (OLD-EXPORT-STATUS is `nil') or
                    ;; if SYMBOL was internal.
                    (when (member old-export-status '(nil :internal))
                      (setf (low:symbol-entry client name package)
                            (values symbol :external old-shadow-status))))))))))))
  ;; TODO: return value?
  )
