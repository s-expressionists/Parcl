(cl:in-package #:parcl-low)

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

;;; Currently, we do not offer any restarts.  The dictionary entry on
;;; USE-PACKAGE does not say that a correctable error has to be
;;; signaled, but in section 11.1.1.2.5, it is said that any time a
;;; name conflict is about to occur, a correctable error is signaled.
;;; So at some point, we must define restarts.  The problem is to
;;; define exactly what restarts are useful, in particular so that
;;; they can be used programmatically.

(defmethod use-packages (client package packages-to-use)
  (let ((added-packages
          (set-difference (use-list client package) packages-to-use)))
    (let ((accessible-symbols '()))
      (map-symbols client package
                   (lambda (symbol)
                     (push (list symbol) accessible-symbols)))
      (loop for package-to-use in added-packages
            do (map-external-symbols
                client package-to-use
                (lambda (symbol)
                  (let ((collision (find symbol accessible-symbols
                                         :key #'car
                                         :test
                                         (lambda (s1 s2)
                                           (symbol-names-equal client s1 s2)))))
                    (if (null collision)
                        (push (list symbol) accessible-symbols)
                        (push accessible-symbols (cdr collision)))))))
      (let ((conflicts
              (remove-if (lambda (x) (null (cdr x))) accessible-symbols)))
        (unless (null conflicts)
          (error 'conflicts
                 :conflicts conflicts)))
      (setf (use-list client package)
            (append (use-list client package) packages-to-use)))))
