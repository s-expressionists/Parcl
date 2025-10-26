(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test find-package.smoke
  (with-mock-package-system ()
    (with-mock-package (package1 #1="foo")
      (is (eq package1 (parcl:find-package package1)))
      (do-string-designators (name #1#)
        (is (eq package1 (parcl:find-package name)))))))

;;; TODO: argument type

(high-test find-package.non-existent
  (with-mock-package-system ()
    (do-string-designators (name "foo")
      (is (null (parcl:find-package name))))))

(high-test find-package.nicknames
  (with-mock-package-system ()
    (with-mock-package (package1 #1="foo")
      (parcl:rename-package package1 #1# '(#2="bar" #3="baz"))
      (do-string-designators (name #1#)
        (is (eq package1 (parcl:find-package name))))
      (do-string-designators (name #2#)
        (is (eq package1 (parcl:find-package name))))
      (do-string-designators (name #3#)
        (is (eq package1 (parcl:find-package name)))))))

;;;; Local nicknames

(high-test (find-package.local-nicknames
            :client-class mock-client-with-local-nicknames)
  ;; TODO: use specific client
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #3="b" package2 package1)
    ;; If the current package is not PACKAGE1, the local nickname(s)
    ;; are not considered.
    (do-string-designators (name #3#)
      (is (null (parcl:find-package name))))
    ;; If the current package is PACKAGE1, the local nickname(s) are
    ;; considered.
    (let ((parcl:*package* package1))
      (do-string-designators (name #3#)
        (is (eq package2 (parcl:find-package name)))))))
