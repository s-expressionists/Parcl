(cl:in-package #:parcl.test)

(in-suite :parcl)

;;; TODO: designators

(high-test unexport.error.forbidden-for-system-package
  (with-mock-package-constellation ((common-lisp "COMMON-LISP") (keyword "KEYWORD"))
    (let ((car (parcl:intern "CAR" common-lisp))
          (key (parcl:intern "KEY" keyword)))
      (parcl:export car common-lisp)
      (assert (eq (nth-value 1 (parcl:find-symbol "KEY" keyword)) :external))
      (flet ((check-forbidden-symbol (symbol package)
               (let ((signaled? nil))
                (handler-bind
                    ((#1=parcl:unexport-forbidden-for-system-package-error
                       (lambda (condition)
                         (setf signaled? t)
                         (is (eq package (parcl:package-error-package condition)))
                         (is (eq symbol  (parcl:symbol-to-unexport    condition)))
                         (let ((restart (find-restart 'parcl::do-nothing)))
                           (is (not (null restart)))
                           (is-false (a:emptyp (princ-to-string restart)))
                           (invoke-restart restart)))))
                  (is (eq t (parcl:unexport symbol package)))
                  (unless signaled?
                    (fiveam:fail "~@<Did not signal ~S condition~@:>" '#1#))))))
        (check-forbidden-symbol car common-lisp)
        (check-forbidden-symbol key keyword)))))
