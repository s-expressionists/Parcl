(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test package-local-nickname.smoke
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (is (equal '() (parcl:package-local-nicknames package1))))))
