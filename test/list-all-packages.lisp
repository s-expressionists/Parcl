(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test list-all-packages.smoke
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (let* ((packages     (parcl:list-all-packages))
           ;; This is a workaround for the fact that the native
           ;; package system will contain more packages than the mock
           ;; constellation we establish here.
           (client-class (class-of parcl:*client*))
           (native?      (search "NATIVE" (package-name
                                           (symbol-package
                                            (class-name client-class))))))
      (if native?
          (is (null (set-difference (list package1 package2) packages
                                    :test #'eq)))
          (is (a:set-equal (list package1 package2) packages :test #'eq))))
    ;; The returned list must be freshly allocated so at the very
    ;; least, two consecutive calls cannot return the same list.
    (is-false (eq (parcl:list-all-packages) (parcl:list-all-packages)))))
