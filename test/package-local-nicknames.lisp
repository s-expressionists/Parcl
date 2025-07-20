(cl:in-package #:parcl.test)

(in-suite :parcl)

(test package-local-nickname.not-implemented
  "Ensure that an error is signaled if the package system does not
support local nicknames."
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (signals error ; TODO: specific error
        (parcl:package-local-nicknames package1)))))

(high-test (package-local-nicknames.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (is (equal '() (parcl:package-local-nicknames package1)))
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #1="b" package2 package1)
        (is (set-equal/equal (list (cons #1# package2))
                             (parcl:package-local-nicknames package1)))))))

(high-test (package-local-nicknames.delete-package
            :client-class mock-client-with-local-nicknames)
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #1="b" package2 package1)
        (is (set-equal/equal (list (cons #1# package2))
                             (parcl:package-local-nicknames package1)))
        (parcl:delete-package package2)
        (is (equal '() (parcl:package-local-nicknames package1)))))))
