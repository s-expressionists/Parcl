(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test unintern.smoke
  ;; TODO: designators
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (let ((symbol1 (parcl:intern #1="bar" package1)))
        (is-true (parcl:unintern symbol1 package1))
        (is (null (parcl:find-symbol #1# package1)))
        (is (null (parcl:symbol-package symbol1)))))))

;;; TODO: shadowing

(high-test unintern.not-present
  ;; TODO: designators
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (let ((symbol1 (parcl:make-symbol #1="bar")))
        (is-false (parcl:unintern symbol1 package1))
        (is (null (parcl:find-symbol #1# package1)))
        (is (null (parcl:symbol-package symbol1)))))))

;; (let ((p1 (make-package "p1")) (p2 (make-package "p2")))
;;         (let ((s (intern "s" p1)))
;;           (export s p1)
;;           (import s p2)
;;           (unintern s p1)
;;           (find-symbol "s" p2)))
;; => #:|s| :INTERNAL

;;; TODO: "uncover name conflict" case

;;; TODO: "pathological" case from the `unintern' entry
