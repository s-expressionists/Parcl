(cl:in-package #:parcl)

;;; This function detects and resolves a conflict between SYMBOL and a
;;; present symbol S in USING-PACKAGE where USING-PACKAGE uses
;;; PACKAGE.  The standard says that such a conflict can be resolved
;;; in favor of SYMBOL by uninterning S in USING-PACKAGE, or by making
;;; S a shadowing symbol in USING-PACKAGE.
(defun detect-and-resolve-export-conflict-1
    (client symbol using-package)
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
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
                    (format stream
                            "Unintern ~s from ~s"
                            conflicting-symbol using-package))
          (return-from detect-and-resolve-export-conflict-1
            (lambda ()
              (unintern client using-package symbol))))
        (shadow ()
          :report (lambda (stream)
                    (format stream
                            "Make ~s a shadowing symbol in ~s"
                            conflicting-symbol using-package))
          (return-from detect-and-resolve-export-conflict-1
            (lambda ()
              (push conflicting-symbol
                    (shadowing-symbols client using-package)))))
        (do-not-export ()
          :report (lambda (stream)
                    (format stream "Abort the EXPORT of ~s" symbol))
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
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (loop with name = (symbol-name client symbol)
        for used-package in (use-list client using-package)
        unless (eq used-package package)
          do (multiple-value-bind (conflicting-symbol present-p)
                 (find-external-symbol client used-package name)
               (when (and present-p
                          (not (eq symbol conflicting-symbol)))
                 (restart-case (error 'symbol-conflict
                                      :package used-package
                                      :conflicting-symbols
                                      (list symbol conflicting-symbol))
                   (make-old-shadowing ()
                     :report (lambda (stream)
                               (format stream
                                       "Make ~s a shadowing symbol in ~s"
                                       conflicting-symbol using-package))
                     (return-from detect-and-resolve-export-conflict-2
                       (lambda ()
                         (push conflicting-symbol
                               (shadowing-symbols client using-package)))))
                   (make-new-shadowing ()
                     :report (lambda (stream)
                               (format stream
                                       "Make ~s a shadowing symbol in ~s"
                                       symbol using-package))
                     (return-from detect-and-resolve-export-conflict-2
                       (lambda ()
                         (push symbol
                               (shadowing-symbols client using-package)))))
                   (do-not-export ()
                     :report (lambda (stream)
                               (format stream
                                       "Abort the EXPORT of ~s"
                                       symbol))
                     (return-from detect-and-resolve-export-conflict-2
                       :abort))))))
  ;; Return NIL to indicate that there was no conflict
  nil)

;;; This function handles the case where SYMBOL is not accessible in
;;; PACKAGE
(defun detect-and-resolve-export-non-accessibility
    (client package symbol)
  #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (multiple-value-bind (putative-symbol status)
      (find-symbol client package (symbol-name client symbol))
    (unless (and (eq putative-symbol symbol)
                 (not (null status)))
      (restart-case (error 'symbol-is-not-accessible
                           :package package
                           :symbol symbol)
        (import ()
          :report (lambda (stream)
                    (format stream
                            "Import ~s into ~s"
                            symbol package))
          (return-from detect-and-resolve-export-non-accessibility
            (lambda ()
              (import client package symbol))))
        (do-not-export ()
          :report (lambda (stream)
                    (format stream
                            "Abort the EXPORT of ~s"
                            symbol))
          (return-from detect-and-resolve-export-non-accessibility
            :abort)))))
  ;; Return NIL to indicate that there was no conflict
  nil)

(defmethod export (client package symbol)
  (let ((action-1
          (detect-and-resolve-export-non-accessibility
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
