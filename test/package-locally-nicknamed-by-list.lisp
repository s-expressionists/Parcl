(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test (package-locally-nicknamed-by.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo"))
    (is (equal '() (parcl:package-locally-nicknamed-by-list package1)))))

(high-test (package-locally-nicknamed-by-list.delete-package
            :client-class mock-client-with-local-nicknames)
  ;; TODO: clean up client creation
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #1="b" package2 package1)
    (is (set-equal/equal (list package1)
                         (parcl:package-locally-nicknamed-by-list package2)))
    (parcl:delete-package package2)
    (is (equal '() (parcl:package-locally-nicknamed-by-list package1)))))
