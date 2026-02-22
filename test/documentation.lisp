(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test documentation.smoke
  (with-mock-package-constellation ((package1 "foo"))
    (is (eq nil (cl:documentation package1 t)))
    (setf (cl:documentation package1 t) #1="test")
    (is (equal #1# (cl:documentation package1 t)))
    (setf (cl:documentation package1 t) nil)
    (is (eq nil (cl:documentation package1 t)))))
