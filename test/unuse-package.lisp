(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test unuse-package.smoke
  ;; TODO: designators
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:use-package package2 package1)
        (parcl:unuse-package package2 package1)
        (is (a:set-equal '() (parcl:package-use-list package1)))
        (is (a:set-equal '() (parcl:package-used-by-list package2)))))))

(high-test unuse-package.idempotent
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (finishes (parcl:unuse-package package2 package1))))))

(high-test unuse-package.used-package-does-not-exist
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (signals parcl::package-does-not-exist-error
        (parcl:unuse-package "bar" package1)))))
