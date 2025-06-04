(cl:in-package #:parcl)

;; For :INHERITED, we start with REMAINING-PACKAGES being the list of
;; all packages to process, with REMAINING-USED-PACKAGES being the
;; used packages of the first package of REMAINING-PACKAGES, and with
;; REMAINING-SYMBOL-ENTRIES being the empty list.

;; For :EXTERNAL or :INTERNAL we start with REMAINING-PACKAGES being
;; the list of all packages to process, and REMAINING-SYMBOL-ENTRIES
;; being the list of entries of the present symbols of the first
;; package of REMAINING-PACKAGES.

(defun symbol-is-external/internal (entry status)
  (ecase status
    (:external
     (member (cdr entry) '(:external :external-shadowing)))
    (:internal
     (member (cdr entry) '(:internal :internal-shadowing)))))

(defun symbol-is-shadowed (symbol package)
  (let* ((symbol-entries
           (parcl-low:symbol-entries parcl:*client* package))
         (present-symbol-entry
           (find symbol symbol-entries
                 :key #'car
                 :test (lambda (s1 s2)
                         (parcl-low:symbol-names-equal
                          parcl:*client* s1 s2)))))
    (not (eq symbol (car present-symbol-entry)))))

(defun make-closure (package-list symbol-types)
  (when (or (null package-list) (null symbol-types))
    (return-from make-closure (lambda () nil)))
  (let ((remaining-symbol-types symbol-types)
        (remaining-packages package-list)
        (remaining-used-packages
          (if (eq (first symbol-types) :inherited)
              (package-used-by-list (first package-list))
              '()))
        (remaining-symbol-entries
          (if (eq (first symbol-types) :inherited)
              '()
              (parcl-low:symbol-entries
               parcl:*client* (first package-list)))))
    (labels
        ((result ()
           (case (first remaining-symbol-types)
             (:inherited
              (tagbody 
               maybe-more-symbols
                 (if (null remaining-symbol-entries)
                     (go no-more-symbols-but-maybe-more-used-packages)
                     (let ((entry (pop remaining-symbol-entries)))
                       (if (and (symbol-is-external/internal entry :external)
                                (not (symbol-is-shadowed
                                      (car entry) (first remaining-packages))))
                           (return-from result
                             (values t
                                     (car entry)
                                     :inherited
                                     (first remaining-packages)))
                           (go maybe-more-symbols))))
               no-more-symbols-but-maybe-more-used-packages
                 (if (null remaining-used-packages)
                     (progn
                       (pop remaining-packages)
                       (if (null remaining-packages)
                           (if (null (rest remaining-symbol-types))
                               (return-from result nil)
                               (progn (pop remaining-symbol-types)
                                      (setf remaining-packages
                                            package-list)
                                      (setf remaining-used-packages
                                            (if (eq (first symbol-types) :inherited)
                                                (package-used-by-list (first package-list))
                                                '()))
                                      (setf remaining-symbol-entries
                                            (if (eq (first symbol-types) :inherited)
                                                '()
                                                (parcl-low:symbol-entries
                                                 parcl:*client* (first package-list))))
                                      (result)))
                           (progn
                             (setf remaining-used-packages
                                   (parcl-low:use-list
                                    parcl:*client* (first remaining-packages)))
                             (go no-more-symbols-but-maybe-more-used-packages))))
                     (let ((used-package (pop remaining-used-packages)))
                       (setf remaining-symbol-entries
                             (parcl-low:symbol-entries
                              parcl:*client* used-package))
                       (go maybe-more-symbols)))))
             ((:external :internal)
              (tagbody
               maybe-more-symbols
                 (if (null remaining-symbol-entries)
                     (progn
                       (pop remaining-packages)
                       (if (null remaining-packages)
                           (if (null (rest remaining-symbol-types))
                               (return-from result nil)
                               (progn (pop remaining-symbol-types)
                                      (setf remaining-packages
                                            package-list)
                                      (setf remaining-used-packages
                                            (if (eq (first symbol-types) :inherited)
                                                (package-used-by-list (first package-list))
                                                '()))
                                      (setf remaining-symbol-entries
                                            (if (eq (first symbol-types) :inherited)
                                                '()
                                                (parcl-low:symbol-entries
                                                 parcl:*client* (first package-list))))
                                      (result)))
                           (progn
                             (setf remaining-symbol-entries
                                   (symbols
                                    (first remaining-packages)))
                             (go maybe-more-symbols))))
                     (let ((entry (pop remaining-symbol-entries)))
                       (if (symbol-is-external/internal entry (first remaining-symbol-types))
                           (return-from result
                             (values t
                                     (car entry)
                                     (first remaining-symbol-types)
                                     (first remaining-packages)))
                           (go maybe-more-symbols))))))))))))
