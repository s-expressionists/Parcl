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

