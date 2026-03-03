(cl:in-package #:parcl.test)

(in-suite :parcl)

(test remove-package-local-nickname.unsupported
  "Ensure that `remove-package-local-nickname' signals an error if the
package system does not support local nicknames."
  (with-mock-package-constellation ((package "foo"))
    (block nil
      (handler-bind ((#2=parcl:feature-not-supported-error
                       (lambda (condition)
                         (is (eq :package-local-nicknames
                                 (parcl:feature condition)))
                         (return))))
        (#1=parcl:remove-package-local-nickname "b" package))
      (fail "~@<~S failed to signal a ~A condition.~@:>" '#1# '#2#))))

(high-test (remove-package-local-nickname.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (parcl:remove-package-local-nickname #2# package1)
    (is (equal '() (parcl:package-local-nicknames package1)))
    (is (equal '() (parcl:package-locally-nicknamed-by-list package2)))))

(high-test (remove-package-local-nickname.twice
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (parcl:remove-package-local-nickname #2# package1)
    (finishes (parcl:remove-package-local-nickname #2# package1))
    (is (equal '() (parcl:package-local-nicknames package1)))))

(high-test (remove-package-local-nickname.non-existent
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (finishes (parcl:remove-package-local-nickname "c" package1))
    (is (set-equal/equal (list (cons #2# package2))
                         (parcl:package-local-nicknames package1)))
    (is (a:set-equal (list package1)
                     (parcl:package-locally-nicknamed-by-list package2)))))

(high-test (add-package-local-nickname.multiple-names
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (parcl:add-package-local-nickname #3="c" package2 package1)
    (parcl:remove-package-local-nickname #2# package1)
    (is (set-equal/equal (list (cons #3# package2))
                         (parcl:package-local-nicknames package1)))
    (is (a:set-equal (list package1)
                     (parcl:package-locally-nicknamed-by-list package2)))
    (parcl:remove-package-local-nickname #3# package1)
    (is (equal '() (parcl:package-local-nicknames package1)))
    (is (equal '() (parcl:package-locally-nicknamed-by-list package2)))))
