(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test package-locally-nicknamed-by.smoke
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (is (equal '() (parcl:package-locally-nicknamed-by package1))))))
