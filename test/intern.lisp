(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test intern.error.argument-type
  (with-mock-package-system ()
    (with-mock-package-constellation ((package1 "foo"))
      (signals type-error (parcl:intern 1 package1))
      (signals type-error (parcl:intern "FOO" 1)))))
