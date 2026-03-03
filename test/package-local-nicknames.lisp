(cl:in-package #:parcl.test)

(in-suite :parcl)

(test package-local-nickname.unsupported
  "Ensure that `package-local-nicknames' signals an error if the package
system does not support local nicknames."
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo"))
    (block nil
      (handler-bind ((#2=parcl:feature-not-supported-error
                       (lambda (condition)
                         (is (eq :package-local-nicknames
                                 (parcl:feature condition)))
                         (return))))
        (#1=parcl:package-local-nicknames package1))
      (fail "~@<~S failed to signal a ~A condition.~@:>" '#1# '#2#))))

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
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #1="b" package2 package1)
    (is (set-equal/equal (list (cons #1# package2))
                         (parcl:package-local-nicknames package1)))
    (parcl:delete-package package2)
    (is (equal '() (parcl:package-local-nicknames package1)))))
