(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test delete-package.smoke
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

(high-test delete-package.nicknames
  (with-mock-package-system ()
    (let ((package (parcl:make-package #1="foo" :nicknames '(#2="bar"))))
      (parcl:delete-package package))
    (is (null (parcl:find-package #1#)))
    (is (null (parcl:find-package #2#)))))

(high-test delete-package.containing-symbol
  (with-mock-package-system ()
    (with-mock-package (package "foo")
      (let ((symbol (parcl:intern "bar" package)))
        (is (eq package (parcl:symbol-package symbol)))
        (parcl:delete-package package)
        (is (null (parcl:symbol-package symbol)))))))

(high-test delete-package.non-existent
  (with-mock-package-system ()
    (do-string-designators (name "does-not-exist")
      (with-fresh-package-system ()
        ;;; TODO: restart
        (signals parcl:package-does-not-exist-error
          (parcl:delete-package name))))))

(high-test delete-package.already-deleted
  (with-mock-package-system ()
    (do-string-designators (name #1="foo")
      (with-fresh-package-system ()
        (with-mock-package (package name)
          (parcl:delete-package package)
          (finishes (parcl:delete-package package)))))))

(high-test delete-package.error.still-in-use
  (with-mock-package-system ()
    (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
      (parcl:use-package package1 package2)
      (let ((signaled?  nil))
        (handler-bind
            ((#1=parcl:package-in-use-error
               (lambda (condition)
                 (setf signaled? t)
                 (is (eq package1 (parcl:package-error-package condition)))
                 (is (eq package2 (parcl:used-by condition)))
                 (let ((restart (find-restart '#2=parcl:unuse-package)))
                   (is-false (null restart))
                   (is-false (alexandria:emptyp (princ-to-string restart)))
                   (invoke-restart restart)))))
          (is (eq t (parcl:delete-package package1))))
        (unless signaled?
          (fiveam:fail "~@<Failed to signal a ~S condition" '#1#))))))
