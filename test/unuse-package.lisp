(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test unuse-package.smoke
  ;; TODO: designators
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:use-package package2 package1)
    (parcl:unuse-package package2 package1)
    (is (a:set-equal '() (parcl:package-use-list package1)))
    (is (a:set-equal '() (parcl:package-used-by-list package2)))))

(high-test unuse-package.idempotent
  "Ensure that `unuse-package' succeeds if the package is already not used."
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (finishes (parcl:unuse-package package2 package1))))

(high-test unuse-package.used-package-does-not-exist
  "Ensure that `unused-package' signals an error for a non-existing package."
  (with-mock-package-constellation ((package1 "foo"))
    (signals parcl:package-does-not-exist-error
      (parcl:unuse-package "bar" package1))))

(high-test unuse-package.complicated
  "TODO"
  (with-mock-package-constellation ((package1 "used") (package2 "using"))
    (let ((symbol (parcl:intern "baz" package1)))
      (parcl:export symbol package1)
      (parcl:use-package package1 package2)
      (is (equal (values symbol :external)  (parcl:find-symbol "baz" package1)))
      (is (equal (values symbol :inherited) (parcl:find-symbol "baz" package2)))
      (is (null (parcl:package-shadowing-symbols package2)))

      (parcl:shadowing-import symbol package2)
      (is (equal (values symbol :external) (parcl:find-symbol "baz" package1)))
      (is (equal (values symbol :internal) (parcl:find-symbol "baz" package2)))
      (is (equal (list symbol) (parcl:package-shadowing-symbols package2)))

      (parcl:unuse-package package1 package2)
      (is (equal (values symbol :external) (parcl:find-symbol "baz" package1)))
      (is (equal (values symbol :internal) (parcl:find-symbol "baz" package2)))
      (is (equal (list symbol) (parcl:package-shadowing-symbols package2))))))
