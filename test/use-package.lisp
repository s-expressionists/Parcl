(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test use-package.smoke
  ;; TODO: designators
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (is (eq t (parcl:use-package package2 package1)))
    (is (a:set-equal (list package2) (parcl:package-use-list package1)))
    (is (a:set-equal (list package1)
                     (parcl:package-used-by-list package2)))))

(high-test use-package.idempotent
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (is (eq t (parcl:use-package package2 package1)))
    (is (eq t (parcl:use-package package2 package1)))
    (is (a:set-equal (list package2) (parcl:package-use-list package1)))
    (is (a:set-equal (list package1)
                     (parcl:package-used-by-list package2)))))

(high-test use-package.used-package-does-not-exist
  (with-mock-package-constellation ((package1 "foo"))
    (signals parcl:package-does-not-exist-error
      (parcl:use-package "bar" package1))))

(high-test use-package.using-keyword-package-forbidden
  "Ensure that `use-package' signals an error if an attempt is made to
use the KEYWORD package in another package"
  (with-mock-package-constellation ((package "foo") (keyword "KEYWORD"))
    (signals parcl:using-keyword-package-forbidden-error
      (parcl:use-package keyword package))))

(high-test use-package.used-by-keyword-package-forbidden
  "Ensure that `use-package' signals an error if an attempt is made to
make the KEYWORD package use other packages."
  ;; This behavior is not related to package locks as the
  ;; specification explicitly forbids calling `use-package' with the
  ;; KEYWORD package as the second argument.
  (with-mock-package-constellation ((package "foo") (keyword "KEYWORD"))
    (signals parcl:used-by-keyword-package-forbidden-error
      (parcl:use-package package keyword))))

(high-test use-package.conflict-with-present
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:intern "baz" package1)
    (parcl:export (parcl:intern "baz" package2) package2)
    (parcl:intern "fez" package1)
    (parcl:export (parcl:intern "fez" package2) package2)
    (signals parcl:symbol-conflicts-error
      (parcl:use-package package2 package1))))

(high-test use-package.conflict-with-inherited/2-packages
  (with-mock-package-constellation ((package1 "foo")
                                    (package2 "bar")
                                    (package3 "baz")) ; TODO: allow specifying symbols
    (parcl:export (parcl:intern "fez" package2) package2)
    (parcl:export (parcl:intern "fez" package3) package3)
    (parcl:use-package package2 package1)
    (signals parcl:symbol-conflicts-error
      (parcl:use-package package3 package1))))

(high-test use-package.conflict-with-inherited/3-packages
  (with-mock-package-constellation ((package1 "foo")
                                    (package2 "bar")
                                    (package3 "baz") ; TODO: allow specifying symbols
                                    (package4 "fez"))
    (parcl:export (parcl:intern "whoop" package2) package2)
    (parcl:export (parcl:intern "whoop" package4) package4)
    (parcl:export (parcl:intern "di" package3) package3)
    (parcl:export (parcl:intern "di" package4) package4)
    ;; (parcl:export (parcl:intern "doo" package3) package3)
    ;; (parcl:export (parcl:intern "doo" package4) package4)
    (parcl:use-package package2 package1)
    (parcl:use-package package3 package1)
    (signals parcl:symbol-conflicts-error ; TODO: check condition slots
      (parcl:use-package package4 package1))))

(high-test use-package.conflict-with-present-and-inherited
  (with-mock-package-constellation ((package1 "foo")
                                    (package2 "bar")
                                    (package3 "baz") ; TODO: allow specifying symbols
                                    )
    (parcl:intern "fez" package1)
    (parcl:export (parcl:intern "fez" package3) package3)
    (parcl:export (parcl:intern "whoop" package2) package2)
    (parcl:export (parcl:intern "whoop" package3) package3)
    (parcl:use-package package2 package1)
    (signals parcl:symbol-conflicts-error
      (parcl:use-package package3 package1))))
