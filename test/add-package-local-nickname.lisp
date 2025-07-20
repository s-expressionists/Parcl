(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test (add-package-local-nickname.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (is (set-equal/equal (list (cons #2# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

(high-test (add-package-local-nickname.twice
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (finishes (parcl:add-package-local-nickname #2# package2 package1))
        (is (set-equal/equal (list (cons #2# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

(high-test (add-package-local-nickname.multiple-names
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (parcl:add-package-local-nickname #3="c" package2 package1)
        (is (set-equal/equal (list (cons #2# package2) (cons #3# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

;;; TODO: multiple local names for the same package
