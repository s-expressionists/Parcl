(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test rename-package.smoke
  ;; TODO: designators
  (with-mock-package-system ()
    (let ((package (parcl:make-package #1="foo" :nicknames '(#2="bar"
                                                             #3="baz"))))
      (is (eq package (parcl:rename-package package #4="fez" #5='(#6="whoop"))))
      ;; New names
      (is (equal #4# (parcl:package-name package))) ; TODO: make a thing for checking all names at once
      (is (set-equal/equal #5# (parcl:package-nicknames package)))
      ;; New environment state
      (is (null (parcl:find-package #1#)))
      (is (null (parcl:find-package #2#)))
      (is (null (parcl:find-package #3#)))
      (is (eq package (parcl:find-package #4#)))
      (is (eq package (parcl:find-package #6#))))))

(high-test rename-package.same-old-and-new-name
  (with-mock-package-constellation ((package #1="foo"))
    (is (string= #1# (parcl:package-name package)))
    (is (set-equal/equal '() (parcl:package-nicknames package)))
    ;; Adding a nickname
    (is (eq package (parcl:rename-package package #1# '(#2="bar"))))
    (is (string= #1# (parcl:package-name package)))
    (is (set-equal/equal '(#2#) (parcl:package-nicknames package)))
    ;; No change
    (is (eq package (parcl:rename-package package #1# '(#2#))))
    (is (string= #1# (parcl:package-name package)))
    (is (set-equal/equal '(#2#) (parcl:package-nicknames package)))))

(high-test rename-package.to-self-as-designator
  (with-mock-package-constellation ((package #1="foo"))
    (is (eq package (parcl:rename-package package package)))
    (is (string= #1# (parcl:package-name package)))))

(high-test rename-package.error.package-does-not-exist
  (with-mock-package-system ()
    (signals parcl:package-does-not-exist-error
      (parcl:rename-package "no-such-package" "foo"))))

(high-test rename-package.error.package-has-been-deleted
  (with-mock-package-constellation ((package "foo"))
    (parcl:delete-package package)
    (signals parcl:package-has-been-deleted-error
      (parcl:rename-package package "bar"))))

(high-test rename-package.error.name-occupied
  (with-mock-package-constellation ((package1 #1="foo") (nil #2="bar"))
    (signals parcl:new-name-occupied-error
      (parcl:rename-package package1 #2#))))

(high-test rename-package.error.nickname-occupied
  (with-mock-package-constellation ((package1 #1="foo") (nil #2="bar"))
    (signals parcl:new-name-occupied-error
      (parcl:rename-package package1 #1# '(#2#)))))
