(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test (package-locally-nicknamed-by.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (is (equal '() (parcl:package-locally-nicknamed-by package1))))))

(high-test (package-locally-nicknamed-by.delete-package
            :client-class mock-client-with-local-nicknames)
  ;; TODO: clean up client creation
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #1="b" package2 package1)
        (is (set-equal/equal (list package1)
                             (parcl:package-locally-nicknamed-by package2)))
        (parcl:delete-package package2)
        (is (equal '() (parcl:package-locally-nicknamed-by package1)))))))
