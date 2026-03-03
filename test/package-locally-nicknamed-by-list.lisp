(cl:in-package #:parcl.test)

(in-suite :parcl)

(test package-locally-nicknamed-by-list.unsupported
  "Ensure that `package-locally-nicknamed-by' signals an error if the
package system does not support local nicknames."
  (with-mock-package-constellation ((package "foo"))
    (block nil
      (handler-bind ((#2=parcl:feature-not-supported-error
                       (lambda (condition)
                         (is (eq :package-local-nicknames
                                 (parcl:feature condition)))
                         (return))))
        (#1=parcl:package-locally-nicknamed-by-list package))
      (fail "~@<~S failed to signal a ~A condition.~@:>" '#1# '#2#))))

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
