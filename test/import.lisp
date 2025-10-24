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

(high-test import.already-present
  "Ensure `import' does not change an already present symbols."
  (with-mock-package-constellation ((package1 "foo"))
    (let ((symbol1 (parcl:intern #1="bar" package1)))
      ;; Already present and internal: no change expected.
      (is-true (parcl:import symbol1 package1))
      (is (equal (values symbol1 :internal)
                 (parcl:find-symbol #1# package1)))
      (is (eq package1 (parcl:symbol-package symbol1)))
      ;; Already present and external: no change expected.
      (parcl:export symbol1 package1)
      (is-true (parcl:import symbol1 package1))
      (is (equal (values symbol1 :external)
                 (parcl:find-symbol #1# package1)))
      (is (eq package1 (parcl:symbol-package symbol1))))))

(high-test import.inherited
  "Ensure `import' handles an inherited symbol correctly."
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:use-package package2 package1)
    (let ((symbol1 (parcl:intern #1="bar" package2)))
      (parcl:export symbol1 package2)
      (is-true (parcl:import symbol1 package1))
      (is (equal (values symbol1 :internal)
                 (parcl:find-symbol #1# package1)))
      (is (eq package2 (parcl:symbol-package symbol1))))))

(high-test import.inherited-but-no-home-package
  "Ensure `import' can set the home package for an inherited symbol."
  (with-mock-package-constellation((package1 "foo")
                                   (package2 "bar")
                                   (package3 "baz"))
    (parcl:use-package package3 package2)
    (parcl:use-package package2 package1)
    (let ((symbol1 (parcl:intern #1="bar" package3)))
      (parcl:export symbol1 package3)
      (parcl:export symbol1 package2)
      (parcl:unintern symbol1 package3)
      ;; SYMBOL1 has no home package but is still inherited in
      ;; PACKAGE1 from PACKAGE2.
      (is-true (parcl:import symbol1 package1))
      (is (equal (values symbol1 :internal)
                 (parcl:find-symbol #1# package1)))
      (is (eq package1 (parcl:symbol-package symbol1))))))

(high-test import.error.already-present
  "Ensure `import' can set the home package for an inherited symbol."
  (with-mock-package-constellation ((package1 "foo"))
    (parcl:intern #1="bar" package1)
    (let ((symbol (parcl:make-symbol #1#)))
      (signals parcl:symbol-conflicts-error
        (parcl:import symbol package1)))))
