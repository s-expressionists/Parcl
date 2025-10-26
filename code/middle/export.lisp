(cl:in-package #:parcl.middle)

;;; This function detects and resolves a conflict between SYMBOL and a
;;; present symbol S in USING-PACKAGE where USING-PACKAGE uses
;;; PACKAGE.  The standard says that such a conflict can be resolved
;;; in favor of SYMBOL by uninterning S in USING-PACKAGE, or by making
;;; S a shadowing symbol in USING-PACKAGE.
(defun detect-and-resolve-export-conflict-1 (client package symbol using-package)
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (conflicting-symbol export-status shadow-status)
        (low:symbol-entry client name using-package)
      (if (and (not (null export-status)) (not shadow-status))
          (restart-case
              (error 'parcl:symbol-conflicts-error
                     :package        package
                     :conflicts      `((,name . ((,symbol . ,package)
                                                 (,conflicting-symbol
                                                  . ,using-package))))
                     :package-labels `((,package       . "exporting package")
                                       (,using-package . "using package")))
            (#1=parcl:unintern ()
              :report (lambda (stream)
                        (parcl::report-restart
                         '#1# stream conflicting-symbol using-package))
              (lambda ()
                (unintern client using-package conflicting-symbol)))
            (#2=parcl:shadow ()
              :report (lambda (stream)
                        (parcl::report-restart
                         '#2# stream conflicting-symbol using-package))
              (lambda ()
                (setf (low:symbol-entry client name using-package)
                      (values conflicting-symbol export-status t))))
            (#3=parcl::do-not-export ()
              :report (lambda (stream)
                        (parcl::report-restart '#3# stream symbol))
              :abort))
          nil)))) ; Return `nil' to indicate that there was no conflict.

;;; This function detects and resolves a conflict between SYMBOL and
;;; an external symbol in some package P that is used by
;;; USING-PACKAGE.  The standard does not mention what possible ways
;;; such a conflict can be resolved, but we think that either symbol
;;; can be imported into USING-PACKAGE as a shadowing symbol.
(defun detect-and-resolve-export-conflict-2/unshadowed
    (client package symbol export-status using-package)
  ;; TODO: can't we use one of the map- functions?
  (loop named nil
        with name = (low:symbol-name client symbol)
        for used-package in (low:use-list client using-package)
        unless (eq used-package package)
          do (multiple-value-bind (conflicting-symbol conflicting-export-status)
                 (low:symbol-entry client name used-package)
               (when (and (eq conflicting-export-status :external)
                          (not (eq symbol conflicting-symbol)))
                 (restart-case
                     (error 'parcl:symbol-conflicts-error
                            :package        package
                            :conflicts      `((,name . ((,symbol . ,package)
                                                        (,conflicting-symbol
                                                         . ,used-package)
                                                        (,symbol
                                                         . ,using-package))))
                            :package-labels `((,package       . "exporting package")
                                              (,used-package  . "used package")
                                              (,using-package . "using package")))
                   (#1=parcl::make-old-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                '#1# stream conflicting-symbol using-package))
                     (return
                       (lambda ()
                         (let ((export-status (or export-status :internal)))
                           (setf (low:symbol-entry client name using-package)
                                 (values conflicting-symbol export-status t))))))
                   (#2=parcl::make-new-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                '#2# stream symbol using-package))
                     (return
                       (lambda ()
                         (let ((export-status (or export-status :internal)))
                           (setf (low:symbol-entry client name using-package)
                                 (values symbol export-status t))))))
                   (#3=parcl::do-not-export ()
                     :report (lambda (stream)
                               (parcl::report-restart '#3# stream symbol))
                     (return :abort)))))
        finally (return nil))) ; Return `nil' to indicate that there was no conflict

(defun detect-and-resolve-export-conflict-2
    (client package symbol using-package)
  (let ((name (low:symbol-name client symbol)))
    (multiple-value-bind (present-symbol export-status shadow-status)
        (low:symbol-entry client name using-package)
      (declare (ignore present-symbol))
      (if shadow-status
          nil      ; Return `nil' to indicate that there was no conflict
          (detect-and-resolve-export-conflict-2/unshadowed
           client package symbol export-status using-package)))))

;;; This function handles the case where SYMBOL is not accessible in
;;; PACKAGE
(defun detect-and-resolve-export-non-accessibility (client package symbol)
  (map-accessible-entries-with-name
   client
   (lambda (containing-package other-symbol export-status shadow-status)
     (declare (ignore containing-package other-symbol export-status shadow-status))
     (return-from detect-and-resolve-export-non-accessibility nil))
   (low:symbol-name client symbol) package)
  (restart-case (error 'parcl:symbol-is-not-accessible-error
                       :package             package
                       :inaccessible-symbol symbol)
    (#1=parcl:import ()
      :report (lambda (stream)
                (parcl::report-restart '#1# stream symbol package))
      (lambda ()
        (import client package symbol)))
    (#2=parcl::do-not-export ()
      :report (lambda (stream)
                (parcl::report-restart '#2# stream symbol))
      :abort)))

(defmethod export ((client t) (package t) (symbol t))
  (let ((action-1 (detect-and-resolve-export-non-accessibility
                   client package symbol)))
    (unless (eq action-1 :abort)
      (let ((action-2
              (loop for using-package in (low:used-by-list client package)
                      thereis (detect-and-resolve-export-conflict-1
                               client package symbol using-package))))
        (unless (eq action-2 :abort)
          (let ((action-3
                  (loop for using-package in (low:used-by-list client package) ; TODO: don't call twice
                          thereis (detect-and-resolve-export-conflict-2
                                   client package symbol using-package))))
            (unless (eq action-3 :abort)
              (unless (null action-1) (funcall action-1))
              (unless (null action-2) (funcall action-2))
              (unless (null action-3) (funcall action-3))
              (progn ; when (and (null action-1) (null action-2) (null action-3))
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
