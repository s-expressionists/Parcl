(cl:in-package #:parcl.test)

(in-suite :parcl)

;;; TODO: designators

(high-test export.already-exported
  (with-mock-package-constellation ((package "old-exporting"))
    (let ((symbol (parcl:intern #1="foo" package)))
      (parcl:export symbol package)
      (parcl:export symbol package)
      (is (eq (nth-value 1 (parcl:find-symbol #1# package)) :external)))))

(high-test export.same-symbol-exported-from-multiple-packages
  (with-mock-package-constellation ((package1 "old-exporting")
                                    (package2 "new-exporting")
                                    (package3 "using"))
    (parcl:use-package package1 package3)
    (parcl:use-package package2 package3)
    (let ((symbol (parcl:intern "foo" package1)))
      (parcl:export symbol package1)
      (parcl:import symbol package2)
      (parcl:export symbol package2))))

(high-test export.not-accessible
  "Ensure that an attempt to export a symbol from a package in which the
symbol is not accessible signals the correct error and establishes the
correct restarts."
  (mapc
   (lambda (restart-and-expected)
     (destructuring-bind (restart-name
                          (expected-export-status1 expected-shadow-status1)
                          (expected-export-status2 expected-shadow-status2))
         restart-and-expected
       (with-mock-package-constellation ((package1 "unrelated")
                                         (package2 "exporting"))
         (let ((symbol (parcl:intern #1="foo" package1)))
           (block nil
             (handler-bind
                 ((parcl:symbol-is-not-accessible-error
                    (lambda (condition)
                      ;; TODO: check condition readers
                      (is-false (a:emptyp (princ-to-string condition)))
                      ;; TODO make a function or macro for this check
                      (cond ((null restart-name)
                             (return))
                            (t
                             (let ((restart (find-restart restart-name)))
                               (is-false (a:emptyp (princ-to-string restart)))
                               (invoke-restart restart)))))))
               (parcl:export symbol package2)))
           (is-symbol-status restart-name package1 #1#
                             expected-export-status1 expected-shadow-status1)
           (is-symbol-status restart-name package2 #1#
                             expected-export-status2 expected-shadow-status2)))))
   '(;; This case simulates unwinding without any of the restart
     ;; that Parcl establishes.
     (nil                  (:internal nil) (nil       nil))
     (parcl:import         (:internal nil) (:external nil))
     (parcl::do-not-export (:internal nil) (nil       nil)))))

;;; TODO: can we turn this into a generic utility?
(defun is-symbol-status (restart-name package symbol-name
                         expected-export-status expected-shadow-status)
  (multiple-value-bind (actual-symbol actual-export-status)
      (parcl:find-symbol symbol-name package)
    (is (eq actual-export-status expected-export-status)
        "~@<After ~A restart, for name ~S in package ~A, expected export ~
         status ~S but got ~S.~@:>"
        restart-name symbol-name package
        expected-export-status actual-export-status)
    (let* ((shadowing-symbols    (parcl:package-shadowing-symbols package))
           (actual-shadow-status (not (null (find actual-symbol shadowing-symbols)))))
      (is (eq actual-shadow-status expected-shadow-status)
          "~@<After ~A restart, for name ~S in package ~A, expected shadow ~
           status ~S but got ~S.~@:>"
          restart-name symbol-name package
          expected-shadow-status actual-shadow-status))))

(high-test export.conflict.1
  "Ensure that `export' signals an error "
  (mapc
   (lambda (restart-and-expected)
     (destructuring-bind (restart-name
                          (expected-export-status1 expected-shadow-status1)
                          (expected-export-status2 expected-shadow-status2))
         restart-and-expected
       (with-mock-package-constellation ((package1 "exporting")
                                         (package2 "using"))
         (parcl:use-package package1 package2)
         (let ((symbol1 (parcl:intern #1="baz" package1)))
           (parcl:intern #1# package2)
           (block nil ; TODO: make an abstraction for the restart stuff
             (handler-bind
                 ((parcl:symbol-conflicts-error
                    (lambda (condition)
                      (is-false (a:emptyp (princ-to-string condition)))
                      ;; TODO: check condition readers
                      (cond ((null restart-name)
                             (return))
                            (t
                             (let ((restart (find-restart restart-name)))
                               (is-true restart "~@<Expected to find a restart named ~S but there is none.~@:>"
                                        restart-name)
                               (is-false (a:emptyp (princ-to-string restart)))
                               (invoke-restart restart)))))))
               (parcl:export symbol1 package1)))
           ;; TODO: check the symbol object that is found for the symbol name
           (is-symbol-status restart-name package1 #1# expected-export-status1 expected-shadow-status1)
           (is-symbol-status restart-name package2 #1# expected-export-status2 expected-shadow-status2)))))
   '(;; This case simulates unwinding without any of the restart
     ;; that Parcl establishes.
     (nil                  (:internal nil) (:internal  nil))
     (parcl:unintern       (:external nil) (:inherited nil))
     (parcl:shadow         (:external nil) (:internal  t))
     (parcl::do-not-export (:internal nil) (:internal  nil)))))

(high-test export.conflict.2
  "Ensure that `export' signals an error and establishes a restart when
two packages that are used by a third package both export symbols with
identical names."
  (mapc
   (lambda (restart-and-expected)
     (destructuring-bind (restart-name
                          (expected-export-status1 expected-shadow-status1)
                          (expected-export-status2 expected-shadow-status2)
                          (expected-export-status3 expected-shadow-status3))
         restart-and-expected
       (with-mock-package-constellation ((package1 "old-exporting")
                                         (package2 "new-exporting")
                                         (package3 "using"))
         (parcl:use-package package1 package3)
         (parcl:use-package package2 package3)
         (let ((symbol1 (parcl:intern #1="foo" package1))
               (symbol2 (parcl:intern #1# package2)))
           (parcl:export symbol1 package1)
           (block nil
             (handler-bind
                 ((parcl:symbol-conflicts-error
                    (lambda (condition)
                      (is-false (a:emptyp (princ-to-string condition)))
                      ;; TODO: check condition readers
                      (cond ((null restart-name)
                             (return))
                            (t
                             (let ((restart (find-restart restart-name)))
                               (is-true restart "~@<Expected to find a restart ~
                                                 named ~S but there is none.~@:>"
                                        restart-name)
                               (is-false (a:emptyp (princ-to-string restart)))
                               (invoke-restart restart)))))))
               (parcl:export symbol2 package2)))
           ;; TODO: check the symbol object that is found for the symbol name
           (is-symbol-status restart-name package1 #1#
                             expected-export-status1 expected-shadow-status1)
           (is-symbol-status restart-name package2 #1#
                             expected-export-status2 expected-shadow-status2)
           (is-symbol-status restart-name package3 #1#
                             expected-export-status3 expected-shadow-status3)))))

   '(;; This case simulates unwinding without any of the restart that
     ;; Parcl establishes.
     (nil                       (:external nil) (:internal nil) (:inherited nil))
     (parcl::make-old-shadowing (:external nil) (:external nil) (:internal  t))
     (parcl::make-new-shadowing (:external nil) (:external nil) (:internal  t))
     ;; TODO: missing: "neither" aka plain cl:shadow, that is interning a new symbol that is shadowing
     (parcl::do-not-export      (:external nil) (:internal nil) (:inherited nil)))))

#++ (let ((package-names '("old-exporting" "new-exporting" "using")))
  (unwind-protect
       (destructuring-bind (package1 package2 package3)
           (mapcar #'make-package package-names)
         (use-package package1 package3)
         (use-package package2 package3)
         (let ((symbol1 (intern #1="foo" package1))
               (symbol2 (intern #1# package2)))
           (export symbol1 package1)
           (export symbol2 package2))
         (clouseau:inspect (list package1 package2 package3)))
    (mapc #'delete-package (reverse package-names))))
