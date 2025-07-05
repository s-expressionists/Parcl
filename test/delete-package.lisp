(cl:in-package #:parcl.test)

(in-suite :parcl)

(test delete-package.smoke
  (with-mock-package-system ()
    (do-string-designators (name #1="foo")
      (with-fresh-package-system ()
        (with-mock-package (package name)
          (parcl:delete-package name)
          (is (null (parcl:package-name package)))
          (is (null (parcl:find-package #1#))))))
    (with-fresh-package-system ()
      (with-mock-package (package #2="bar")
        (parcl:delete-package package)
        (is (null (parcl:package-name package)))
        (is (null (parcl:find-package #2#)))))))

(test delete-package.nicknames
  (with-mock-package-system ()
    (let ((package (parcl:make-package #1="foo" :nicknames '(#2="bar"))))
      (parcl:delete-package package))
    (is (null (parcl:find-package #1#)))
    (is (null (parcl:find-package #2#)))))

(test delete-package.containing-symbol
  (with-mock-package-system ()
    (with-mock-package (package "foo")
      (let ((symbol (parcl:intern "bar" package)))
        (is (eq package (parcl:symbol-package symbol)))
        (parcl:delete-package package)
        (is (null (parcl:symbol-package symbol)))))))

(test delete-package.non-existent
  (with-mock-package-system ()
    (do-string-designators (name "does-not-exist")
      (with-fresh-package-system ()
        (signals parcl::package-does-not-exist-error
          (parcl:delete-package name))))))

(test delete-package.already-deleted
  (with-mock-package-system ()
    (do-string-designators (name #1="foo")
      (with-fresh-package-system ()
        (with-mock-package (package name)
          (parcl:delete-package package)
          (signals parcl::package-has-been-deleted-error
            (parcl:delete-package package)))))))

(test delete-package.still-in-use
  (with-mock-package-system ()
    (with-fresh-package-system ()
      (with-mock-package (package1 "foo")
        (with-mock-package (package2 "bar")
          (parcl:use-package package1 package2)
          (signals parcl::package-in-use-error
            (parcl:delete-package package1)))))))

;;; TODO: restarts
