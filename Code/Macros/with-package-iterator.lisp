(cl:in-package #:parcl)

;; For :INHERITED, we start with REMAINING-PACKAGES-TO-PROCESS being
;; the list of all packages to process, with REMAINING-USED-PACKAGES
;; being the used packages of the first package of
;; REMAINING-PACKAGES-TO-PROCESS, and with REMAINING-SYMBOLS being the
;; empty list.

;; For :EXTERNAL or :INTERNAL we start with
;; REMAINING-PACKAGES-TO-PROCESS being the list of all packages to
;; process, and REMAINING-SYMBOLS being the present symbols of the
;; first package of REMAINING-PACKAGES-TO-PROCESS.

(defun make-closure (package-list symbol-types)
  (let ((remaining-packages-to-process package-list)
        (remaining-used-packages
          (package-used-by-list (first package-list)))
        (remaining-symbols '()))
    (lambda ()
      (block nil
        (case (first symbol-types)
          (:inherited
           (tagbody 
            maybe-more-symbols
              (if (null remaining-symbols)
                  (go no-more-symbols-but-maybe-more-used-packages)
                  (let ((symbol (pop remaining-symbols)))
                    (if (and (symbol-is-external symbol)
                             (symbol-is-not-shadowed symbol))
                        (return)
                        (go maybe-more-symbols))))
            no-more-symbols-but-maybe-more-used-packages
              (if (null remaining-used-packages)
                  (progn
                    (pop remaining-packages-to-process)
                    (if (null remaining-packages-to-process)
                        (return nil)
                        (progn
                          (setf remaining-used-packages
                                (used-packages
                                 (first remaining-packages-to-process)))
                          (go no-more-symbols-but-maybe-more-used-packages))))
                  (let ((used-package (pop remaining-used-packages)))
                    (setf remaining-symbols (present-symbols used-package))
                    (go maybe-more-symbols)))))
          (:external
           (tagbody
            maybe-more-symbols
              (if (null remaining-symbols)
                  (progn
                    (pop remaining-packages-to-process)
                    (if (null remaining-packages-to-process)
                        (return nil)
                        (progn
                          (setf remaining-symbols
                                (symbols
                                 (first remaining-packages-to-process)))
                          (go maybe-more-symbols))))
                  (let ((symbol (pop remaining-symbols)))
                    (if (symbol-is-external symbol)
                        (return)
                        (go maybe-more-symbols))))))
          (:internal
           (tagbody
            maybe-more-symbols
              (if (null remaining-symbols)
                  (progn
                    (pop remaining-packages-to-process)
                    (if (null remaining-packages-to-process)
                        (return nil)
                        (progn
                          (setf remaining-symbols
                                (symbols
                                 (first remaining-packages-to-process)))
                          (go maybe-more-symbols))))
                  (let ((symbol (pop remaining-symbols)))
                    (if (symbol-is-internal symbol)
                        (return)
                        (go maybe-more-symbols)))))))))))
