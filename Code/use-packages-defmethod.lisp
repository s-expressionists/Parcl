(cl:in-package #:parcl)

(define-condition conflicts ()
  ((%conflicts
      :initarg :conflicts
      :reader conflicts))
  (:report (lambda (condition stream)
             (format stream "Conflicts:~%")
             (loop for entries being each hash-value of (conflicts condition)
                   do (loop for (symbol . packages) in entries
                            do (format stream "Symol ~s from packages" symbol)
                            (loop for package in packages
                                  do (format stream " ~s" package))
                            (terpri stream))))))

;;; Currently, we do not offer any restarts, and the standard does not
;;; require a correctable error to be signaled here. But it would
;;; obviously be nice to have some restarts some day. The problem  is to
;;; define exactly what restarts are useful, in particular so that they
;;; can be used programmatically.

(defmethod use-packages (client package packages-to-use)
  (let (;; The keys of hash table are symbol names. The value of a key
        ;; is a list with one element for each distinct symbol with the
        ;; key as a name. Each element is a list where the CAR is the
        ;; symbol, and the CDR is a list of packages for which there
        ;; might be a conflict.
        (conflicts-table (make-hash-table :test #'equal)))
    (flet ((maybe-add-symbol (symbol supplying-package)
             (unless (member symbol (shadowing-symbols client package))
               (let* ((name (symbol-name client symbol))
                      (conflicts (gethash name conflicts-table))
                      (entry (find symbol conflicts
                                   :test #'eq :key #'car)))
                 (if (null entry)
                     (push (list symbol supplying-package)
                           (gethash name conflicts-table))
                     (push supplying-package
                           (cdr entry)))))))
      (loop for package in packages-to-use
            do (loop for symbol in (external-symbols client package)
                     do (maybe-add-symbol symbol package)))
      ;; It is possible that one of the already used packages has a
      ;; symbol that conflicts.
      (loop for package in (use-list client package)
            do (loop for symbol in (external-symbols client package)
                     do (maybe-add-symbol symbol package)))
      ;; We also need to check the internal and external symbos of
      ;; PACKAGE.
      (loop for symbol in (internal-symbols client package)
            do (maybe-add-symbol symbol package))
      (loop for symbol in (external-symbols client package)
            do (maybe-add-symbol symbol package))
      ;; Remove every entry in the hash table that has a single element.
      (loop for name being each hash-key of conflicts-table
              using (hash-value conflicts)
            when (= (length conflicts) 1)
              do (remhash name conflicts-table))
      ;; We can now check for conflicts.
      (when (plusp (hash-table-count conflicts-table))
        (error 'conflicts
               :conflicts conflicts-table))
      (setf (use-list client package)
          (union (use-list client package) packages-to-use)))))
