(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(test with-package-iterator.smoke
  "Smoke test for the `with-package-iterator' macro."
  (mapc
   (lambda (arguments-and-expected)
     (destructuring-bind (packages symbol-types expected)
         arguments-and-expected
       (with-mock-package-constellation ((package1 "P1") (package2 "P2"))
         (parcl:intern "BAR" package1)
         (parcl:export (parcl:intern "BAZ" package1) package1)
         (parcl:intern "FEZ" package2)
         (parcl:export (parcl:intern "WOO" package2) package2)
         (parcl:use-package package1 package2)
         (let ((result
                 (eval
                  `(parcl:with-package-iterator (i '(,@packages) ,@symbol-types)
                     (loop :for values = (multiple-value-list (i))
                           :for (more? symbol status) = values
                           :if more?
                             :collect (cons symbol status)
                           :else
                             ;; The final call is specified to return
                             ;; a single value.
                             :do (is (= 1 (length values)))
                                 (loop-finish)))))
               (expected
                 (loop :for (package-name symbol-name status)
                         :in expected
                       :for package = (parcl:find-package package-name)
                       :for symbol = (parcl:find-symbol symbol-name package)
                       :do (assert (eq (parcl:symbol-package symbol) package))
                       :collect (cons symbol status))))
           (is (set-equal/equal expected result))))))
   `((()
      (:internal)
      ())
     ;; Package without inheritance
     (("P1")
      (:internal)
      (("P1" "BAR" :internal)))
     (("P1")
      (:external)
      (("P1" "BAZ" :external)))
     (("P1")
      (:internal :external)
      (("P1" "BAR" :internal) ("P1" "BAZ" :external)))
     (("P1")
      (:internal :external :inherited)
      (("P1" "BAR" :internal) ("P1" "BAZ" :external)))
     ;; Package with inheritance
     (("P2")
      (:internal)
      (("P2" "FEZ" :internal)))
     (("P2")
      (:external)
      (("P2" "WOO" :external)))
     (("P2")
      (:internal :external)
      (("P2" "FEZ" :internal) ("P2" "WOO" :external)))
     (("P2")
      (:internal :external :inherited)
      (("P2" "FEZ" :internal) ("P2" "WOO" :external) ("P1" "BAZ" :inherited)))
     ;; Two packages
     (("P1" "P2")
      (:internal)
      (("P1" "BAR" :internal) ("P2" "FEZ" :internal)))
     (("P1" "P2")
      (:external)
      (("P1" "BAZ" :external) ("P2" "WOO" :external)))
     (("P1" "P2")
      (:internal :external)
      (("P1" "BAR" :internal) ("P1" "BAZ" :external)
       ("P2" "FEZ" :internal) ("P2" "WOO" :external)))
     (("P1" "P2")
      (:internal :external :inherited)
      (("P1" "BAR" :internal) ("P1" "BAZ" :external)
       ("P2" "FEZ" :internal) ("P2" "WOO" :external) ("P1" "BAZ" :inherited))))))

(test with-package-iterator.expansion-error.no-symbol-types
  "Ensure that `with-package-iterator' signals a syntax error if no
symbol types are supplied."
  (signals parcl::macro-syntax-error
    (macroexpand '(parcl:with-package-iterator (i '())))))

(test with-package-iterator.expansion-error.invalid-symbol-type
  "Ensure that `with-package-iterator' signals a syntax error if an
invalid symbol type is supplied."
  (signals parcl::macro-syntax-error
    (macroexpand '(parcl:with-package-iterator (i '() :invalid)))))
