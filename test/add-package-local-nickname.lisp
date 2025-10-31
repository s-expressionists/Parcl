(cl:in-package #:parcl.test)

(in-suite :parcl)

(high-test (add-package-local-nickname.smoke
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (is (set-equal/equal (list (cons #2# package2))
                         (parcl:package-local-nicknames package1)))
    (is (a:set-equal
         (list package1)
         (parcl:package-locally-nicknamed-by-list package2)))))

(high-test (add-package-local-nickname.twice
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (finishes (parcl:add-package-local-nickname #2# package2 package1))
    (is (set-equal/equal (list (cons #2# package2))
                         (parcl:package-local-nicknames package1)))
    (is (a:set-equal
         (list package1)
         (parcl:package-locally-nicknamed-by-list package2)))))

(high-test (add-package-local-nickname.multiple-names
            :client-class mock-client-with-local-nicknames)
  ;; TODO: designators?
  (with-mock-package-constellation ((package1 "foo") (package2 "bar"))
    (parcl:add-package-local-nickname #2="b" package2 package1)
    (parcl:add-package-local-nickname #3="c" package2 package1)
    (is (set-equal/equal (list (cons #2# package2) (cons #3# package2))
                         (parcl:package-local-nicknames package1)))
    (is (a:set-equal
         (list package1)
         (parcl:package-locally-nicknamed-by-list package2)))))

;;; TODO: multiple local names for the same package

(high-test (add-package-local-nickname.error.refers-to-different-package
            :client-class mock-client-with-local-nicknames)
  (flet ((one-restart (restart-name expected-value expected-nicknamed-package)
           (with-mock-package-constellation ((package1 "foo")
                                             (package2 "bar")
                                             (package3 "baz"))
             (parcl:add-package-local-nickname #1="b" package2 package1)
             (let ((expected-nicknamed-package (parcl:find-package expected-nicknamed-package))
                   (signaled?                  nil))
               (handler-bind ((#2=parcl:nickname-refers-to-different-package-error
                                (lambda (condition)
                                  (is (eq package1 (parcl:package-error-package condition)))
                                  (setf signaled? t)
                                  (let ((restart (find-restart restart-name)))
                                    (is-false (null restart))
                                    (is-false (alexandria:emptyp (princ-to-string restart)))
                                    (invoke-restart restart)))))
                 (is (eq expected-value (parcl:add-package-local-nickname
                                         #1# package3 package1)))
                 (unless signaled?
                   (fiveam:fail "Failed to signal a ~S condition" '#2#))
                 (is (eq expected-nicknamed-package
                         (alexandria:assoc-value
                          (parcl:package-local-nicknames package1) #1#))))))))
    (one-restart 'parcl::use-new-nicknamed-package  t   "baz")
    (one-restart 'parcl::keep-old-nicknamed-package nil "bar")))
