(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test remove-package-local-nickname.smoke
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (parcl:remove-package-local-nickname #2# package1)
        (is (equal '() (parcl:package-local-nicknames package1)))
        (is (equal '() (parcl:package-locally-nicknamed-by package2)))))))

(high-test remove-package-local-nickname.twice
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (parcl:remove-package-local-nickname #2# package1)
        (finishes (parcl:remove-package-local-nickname #2# package1))
        (is (equal '() (parcl:package-local-nicknames package1)))
        (is (equal '() (parcl:package-locally-nicknamed-by package2)))))))

(high-test remove-package-local-nickname.non-existent
  ;; TODO: designators?
  (with-mock-package-system ()
    (with-mock-package (package1 "foo")
      (with-mock-package (package2 "bar")
        (parcl:add-package-local-nickname #2="b" package2 package1)
        (finishes (parcl:remove-package-local-nickname "c" package1))
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
        (parcl:remove-package-local-nickname #2# package1)
        (is (set-equal/equal (list (list #3# package2))
                             (parcl:package-local-nicknames package1)))
        (is (a:set-equal (list package1)
                         (parcl:package-locally-nicknamed-by package2)))
        (parcl:remove-package-local-nickname #3# package1)
        (is (equal '() (parcl:package-local-nicknames package1)))
        (is (equal '() (parcl:package-locally-nicknamed-by package2)))))))
