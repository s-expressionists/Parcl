(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test import.smoke
  ;; TODO: designators
  (with-mock-package-constellation ((package1 "foo"))
    (let ((symbol1 (parcl:make-symbol #1="bar")))
      (is-true (parcl:import symbol1 package1))
      (is (equal (values symbol1 :internal)
                 (parcl:find-symbol #1# package1)))
      (is (eq package1 (parcl:symbol-package symbol1))))))

(high-test import.different-home-package
  "Ensure `import' does not change an existing home package."
  ;; TODO: designators
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (let ((symbol1 (parcl:intern #1="bar" package1)))
      (is-true (parcl:import symbol1 package2))
      (is (eq symbol1 (parcl:find-symbol #1# package1)))
      (is (eq symbol1 (parcl:find-symbol #1# package2)))
      (is (eq package1 (parcl:symbol-package symbol1))))))

