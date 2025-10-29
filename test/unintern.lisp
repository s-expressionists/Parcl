(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test unintern.smoke
  ;; TODO: designators
  (with-mock-package-constellation ((package1 "foo"))
    (let ((symbol1 (parcl:intern #1="bar" package1)))
      (is-true (parcl:unintern symbol1 package1))
      (is (null (parcl:find-symbol #1# package1)))
      (is (null (parcl:symbol-package symbol1))))))

;;; TODO: shadowing

(high-test unintern.not-present
  (with-mock-package-constellation ((package1 "foo"))
    (let ((symbol1 (parcl:make-symbol #1="bar")))
      (is-false (parcl:unintern symbol1 package1))
      (is (null (parcl:find-symbol #1# package1)))
      (is (null (parcl:symbol-package symbol1))))))

(high-test unintern.different-symbol
  (with-mock-package-constellation ((package "foo"))
    (parcl:intern #1="foo" package)
    (let ((symbol2 (parcl:make-symbol #1#)))
      (is-false (parcl:unintern symbol2 package)))))

(high-test unintern.shadowing-no-conflict
  (with-mock-package-constellation ((package1 "using")
                                    (package2 "exporting"))
    (parcl:use-package package2 package1)
    (let ((symbol1 (progn
                     (parcl:shadow #1="foo" package1)
                     (parcl:find-symbol #1# package1)))
          (symbol2 (parcl:intern #1# package2)))
      (parcl:export symbol2 package2)
      (is-true (parcl:unintern symbol1 package1))
      (is (eq symbol2 (parcl:find-symbol #1# package1))))))

(high-test unintern.shadowing-conflict
  (mapc
   (lambda (restart-and-expected)
     (destructuring-bind (restart-name (expected-export-status expected-shadow-status))
         restart-and-expected
       (with-mock-package-constellation ((package1 "using")
                                         (package2 "exporting1")
                                         (package3 "exporting2"))
         (parcl:use-package package2 package1)
         (parcl:use-package package3 package1)
         (let ((symbol1 (progn
                          (parcl:shadow #1="foo" package1)
                          (parcl:find-symbol #1# package1)))
               (symbol2 (parcl:intern #1# package2))
               (symbol3 (parcl:intern #1# package3)))
           (parcl:export symbol2 package2)
           (parcl:export symbol3 package3)
           (block nil
             (handler-bind
                 ((parcl:symbol-conflicts-error
                    (lambda (condition)
                      (is-false (a:emptyp (princ-to-string condition)))
                      (cond ((null restart-name)
                             (return))
                            (t
                             (let ((restart (find-restart restart-name)))
                               (is-true restart "~@<Expected to find a restart named ~S but there is none.~@:>"
                                        restart-name)
                               (is-false (a:emptyp (princ-to-string restart)))
                               (invoke-restart restart)))))))
               (parcl:unintern symbol1 package1)))
           (is-symbol-status restart-name package1 #1# expected-export-status expected-shadow-status)))))
   '(;; This case simulates unwinding without any of the restart
     ;; that Parcl establishes.
     (nil                    (:internal t))
     (parcl::abort-operation (:internal t)))))

;; (let ((p1 (make-package "p1")) (p2 (make-package "p2")))
;;         (let ((s (intern "s" p1)))
;;           (export s p1)
;;           (import s p2)
;;           (unintern s p1)
;;           (find-symbol "s" p2)))
;; => #:|s| :INTERNAL

;;; TODO: "uncover name conflict" case

;;; TODO: "pathological" case from the `unintern' entry
