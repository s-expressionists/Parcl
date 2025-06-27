(cl:in-package #:parcl-low)

;;; This function detects and resolves a conflict between SYMBOL and a
;;; present symbol S in USING-PACKAGE where USING-PACKAGE uses
;;; PACKAGE.  The standard says that such a conflict can be resolved
;;; in favor of SYMBOL by uninterning S in USING-PACKAGE, or by making
;;; S a shadowing symbol in USING-PACKAGE.
(defun detect-and-resolve-export-conflict-1 (client symbol using-package)
  (multiple-value-bind (conflicting-symbol status)
      (find-symbol client using-package (symbol-name client symbol))
    (when (and (or (eq status :internal) (eq status :external))
               (not (member conflicting-symbol
                            (shadowing-symbols client using-package)
                            :test #'eq)))
      (restart-case (error 'symbol-conflict
                           :package using-package
                           :conflicting-symbols
                           (list symbol conflicting-symbol))
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
              (push conflicting-symbol
                    (shadowing-symbols client using-package)))))
        (do-not-export ()
          :report (lambda (stream)
                    (parcl::report-restart 'do-not-export stream symbol stream))
          (return-from detect-and-resolve-export-conflict-1
            :abort)))))
  ;; Return NIL to indicate that there was no conflict
  nil)

;;; This function detects and resolves a conflict between SYMBOL and
;;; an external symbol is some package P that is used by
;;; USING-PACKAGE.  The standard does not mention what possible ways
;;; such a conflict can be resolved, but we think that either symbol
;;; can be imported into USING-PACKAGE as a shadowing symbol.
(defun detect-and-resolve-export-conflict-2
    (client package symbol using-package)
  (loop with name = (symbol-name client symbol)
        for used-package in (use-list client using-package)
        unless (eq used-package package)
          do (multiple-value-bind (conflicting-symbol status)
                 (find-present-symbol client used-package name)
               (when (and (eq status :external)
                          (not (eq symbol conflicting-symbol)))
                 (restart-case (error 'symbol-conflict
                                      :package used-package
                                      :conflicting-symbols
                                      (list symbol conflicting-symbol))
                   (make-old-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart 'make-old-shadowing
                                                      stream
                                                      conflicting-symbol
                                                      using-package))
                     (return-from detect-and-resolve-export-conflict-2
                       (lambda ()
                         (push conflicting-symbol
                               (shadowing-symbols client using-package)))))
                   (make-new-shadowing ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                'make-new-shadowing stream symbol using-package))
                     (return-from detect-and-resolve-export-conflict-2
                       (lambda ()
                         (push symbol
                               (shadowing-symbols client using-package)))))
                   (do-not-export ()
                     :report (lambda (stream)
                               (parcl::report-restart
                                'do-not-export stream symbol))
                     (return-from detect-and-resolve-export-conflict-2
                       :abort))))))
  ;; Return NIL to indicate that there was no conflict
  nil)

;;; This function handles the case where SYMBOL is not accessible in
;;; PACKAGE
(defun detect-and-resolve-export-non-accessibility (client package symbol)
  (multiple-value-bind (putative-symbol status)
      (find-symbol client package (symbol-name client symbol))
    (if (and (eq putative-symbol symbol)
             (not (null status)))
        nil ; Return NIL to indicate that there was no conflict
        (restart-case (error 'symbol-is-not-accessible
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
            :abort)))))

(defmethod export (client package symbol)
  (let ((action-1 (detect-and-resolve-export-non-accessibility
                   client package symbol)))
    (unless (eq action-1 :abort)
      (let ((action-2
              (loop for using-package in (used-by-list client package)
                      thereis (detect-and-resolve-export-conflict-1
                               client symbol using-package))))
        (unless (eq action-2 :abort)
          (let ((action-3
                  (loop for using-package in (used-by-list client package)
                        thereis (detect-and-resolve-export-conflict-2
                                 client package symbol using-package))))
            (unless (eq action-3 :abort)
              (unless (null action-1) (funcall action-1))
              (unless (null action-2) (funcall action-2))
              (unless (null action-3) (funcall action-3))
              (when (and (null action-1) (null action-2) (null action-3))
                (ensure-present-symbol client package symbol :external)))))))))
