(cl:in-package #:parcl.test)

(in-suite :parcl)

;;; TODO: designators

(high-test unexport.forbidden-for-system-package
  (with-mock-package-constellation ((common-lisp "COMMON-LISP") (keyword "KEYWORD"))
    (let ((car (parcl:intern "CAR" common-lisp))
          (key (parcl:intern "KEY" keyword)))
      (parcl:export car common-lisp)
      (assert (eq (nth-value 1 (parcl:find-symbol "KEY" keyword)) :external))
      ;; TODO: check readers of signaled conditions
      (signals parcl:unexport-forbidden-for-system-package-error
        (parcl:unexport car common-lisp))
      (signals parcl:unexport-forbidden-for-system-package-error
        (parcl:unexport key keyword)))))
