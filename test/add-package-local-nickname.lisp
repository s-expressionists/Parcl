(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test add-package-local-nickname.smoke
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (is (set-equal/equal (list (list #2# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

(high-test add-package-local-nickname.twice
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (finishes (parcl:add-package-local-nickname #2# package2 package1))
        (is (set-equal/equal (list (list #2# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

(high-test add-package-local-nickname.multiple-names
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (parcl:add-package-local-nickname #3="c" package2 package1)
        (is (set-equal/equal (list (list #2# package2) (list #3# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))))))

;;; TODO: multiple local names for the same package
