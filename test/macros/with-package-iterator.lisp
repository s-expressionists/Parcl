(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(high-test with-package-iterator.smoke
  "Smoke test for the `with-package-iterator' macro."
  (with-mock-package-constellation ((package1 "P1") (package2 "P2"))
    ;; Setup.
    (parcl:intern "BAR" package1)
    (parcl:export (parcl:intern "BAZ" package1) package1)
    (parcl:intern "FEZ" package2)
    (parcl:export (parcl:intern "WOO" package2) package2)
    (parcl:use-package package1 package2)
    ;; Perform various queries on the defined packages and symbols.
    (mapc
     (lambda (arguments-and-expected)
       (destructuring-bind (packages symbol-types expected)
           arguments-and-expected
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
           (is (set-equal/equal expected result)))))
     `((()
        (:internal)
        ())
       ;; Designators
       ("P1"                        (:external) (("P1" "BAZ" :external)))
       (,(parcl:make-symbol "P1")   (:external) (("P1" "BAZ" :external)))
       (,package1                   (:external) (("P1" "BAZ" :external)))
       (("P1")                      (:external) (("P1" "BAZ" :external)))
       ((,(parcl:make-symbol "P1")) (:external) (("P1" "BAZ" :external)))
       ((,package1)                 (:external) (("P1" "BAZ" :external)))
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
         ("P2" "FEZ" :internal) ("P2" "WOO" :external) ("P1" "BAZ" :inherited)))
       ;; Repeated symbol type
       (("P1")
        (:internal :internal)
        (("P1" "BAR" :internal)))
       ;; Repeated package
       (("P1" "P1")
        (:internal)
        (("P1" "BAR" :internal)
         ("P1" "BAR" :internal)))))))

(high-test with-package-iterator.iterate-at-end
  "Ensure that the iterator established by `with-package-iterator'
signals an error when called after reaching the end."
  ;; Invoking the iterator again after it has reached the end is
  ;; undefined behavior but we guarantee that `iterator-at-end-error'
  ;; is signaled.
  (with-mock-package-constellation ((nil "P1"))
    (parcl:with-package-iterator (i "P1" :internal)
      (is (equal (values nil) (i)))
      (signals parcl:iterator-at-end-error (i)))))

(high-test with-package-iterator.deleted-package
  "Ensure that passing a deleted package to `with-package-iterator'
causes a `package-has-been-deleted-error' to be signaled."
  ;; This behavior is not mentioned in the specification but we
  ;; guarantee it.
  (with-mock-package-constellation ((package1 "P1"))
    (parcl:delete-package package1)
    (signals parcl:package-has-been-deleted-error
      (parcl:with-package-iterator (i package1 :internal)
        (i)))))

;;; TODO: test corner cases
;;; + shadowing

(test with-package-iterator.syntax-errors
  "Ensure that `with-package-iterator' signals appropriate errors for
syntax errors in the macro invocation."
  ;; Syntax error for no symbol types.
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:with-package-iterator (i '()))))
  ;; Syntax error for invalid symbol type.
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:with-package-iterator (i '() :invalid)))))
