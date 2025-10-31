(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test make-package.smoke
  (with-mock-package-system ()
    (do-string-designators (name #1="foo")
      (with-fresh-package-system ()
        (let ((package (parcl:make-package name)))
          (is-true (parcl:packagep package))
          (is (equal #1# (parcl:package-name package)))
          (is (equal '() (parcl:package-nicknames package)))
          (is-true (eq package (parcl:find-package package)))
          (do-string-designators (name2 #1#)
            (is-true (eq package (parcl:find-package name2)))))))))

(high-test make-package.nicknames
  (with-mock-package-system ()
    (do-string-designators (nickname #1="foo")
      (with-fresh-package-system ()
        (let ((package (parcl:make-package #2="bar" :nicknames (list nickname))))
          (is-true (parcl:packagep package))
          (is (equal #2# (parcl:package-name package)))
          (is (equal (list #1#) (parcl:package-nicknames package)))
          (is-true (eq package (parcl:find-package package)))
          (do-string-designators (name #1#)
            (is-true (eq package (parcl:find-package name))))
          (do-string-designators (name #2#)
            (is-true (eq package (parcl:find-package name)))))))))

(high-test make-package.already-exists
  (with-mock-package-system ()
    (do-string-designators (name1 #1="foo")
      (with-fresh-package-system ()
        (parcl:make-package name1)
        (do-string-designators (name2 #1#)
          (signals parcl:package-name-occupied-error
            (parcl:make-package name2)))
        (do-string-designators (name2 #1#)
          (do-string-designators (name3 "bar")
            (signals parcl:package-name-occupied-error
              (parcl:make-package name3 :nicknames (list name2)))))))))

(high-test make-package.recover.return-existing
  (with-mock-package-system ()
    (with-mock-package (package #1="foo")
      (handler-bind ((parcl:package-name-occupied-error
                       (lambda (condition)
                         (declare (ignore condition))
                         (let ((restart (find-restart 'parcl::return-existing)))
                           (is-true restart "~@<Expected to find a restart named ~S but there is none.~@:>"
                                    'parcl::return-existing)
                           (is (not (= 0 (length (princ-to-string restart)))))
                           (invoke-restart restart)))))
        (is (eq package (parcl:make-package #1#)))))))
