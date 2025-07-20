(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test rename-package.smoke
  ;; TODO: designators
  (with-mock-package-system ()
    (let ((package (parcl:make-package #1="foo" :nicknames '(#2="bar"
                                                             #3="baz"))))
      (parcl:rename-package package #4="fez" #5='(#6="whoop"))
      ;; New names
      (is (equal #4# (parcl:package-name package))) ; TODO: make a thing for checking all names at once
      (is (set-equal/equal #5# (parcl:package-nicknames package)))
      ;; New environment state
      (is (null (parcl:find-package #1#)))
      (is (null (parcl:find-package #2#)))
      (is (null (parcl:find-package #3#)))
      (is (eq package (parcl:find-package #4#)))
      (is (eq package (parcl:find-package #6#))))))

(high-test rename-package.name-occupied
  (with-mock-package-system ()
    (with-mock-package (package1 #1="foo")
      (with-mock-package (nil #2="bar")
        (signals parcl::package-name-occupied-error
          (parcl:rename-package package1 #2#))))))

(high-test rename-package.nickname-occupied
  (with-mock-package-system ()
    (with-mock-package (package1 #1="foo")
      (with-mock-package (nil #2="bar")
        (signals parcl::package-name-occupied-error
          (parcl:rename-package package1 #1# '(#2#)))))))
