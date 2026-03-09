(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

;;; `do-external-symbols'

(test do-external-symbols.empty
  "Test `do-external-symbols' with an empty package."
  (with-mock-package-constellation ((package "package"))
    (let ((symbols '())
          result)
      (setf result (parcl:do-external-symbols (symbol package :result)
                     (push symbol symbols)))
      (is (eq    :result result))
      (is (equal '()     symbols)))))

(test do-external-symbols.smoke
  "Smoke test for the `do-external-symbols' macro."
  (with-mock-package-constellation ((package "package"))
    (let ((symbol1 (parcl:intern "foo" package))
          (symbol2 (parcl:intern "bar" package))
          (symbols '())
          result)
      (declare (ignore symbol1))
      (parcl:export symbol2 package)
      (setf result (parcl:do-external-symbols (symbol package symbols)
                     (push symbol symbols)))
      (is (eq    symbols        result))
      (is (equal (list symbol2) symbols)))))

(test do-external-symbols.syntax-errors
  "Ensure that `do-external-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-external-symbols (s) . 1))))

;;; `do-symbols'

(test do-symbols.empty ()
  "Test `do-symbols' with an empty package."
  (with-mock-package-constellation ((package "package"))
    (let ((symbols '())
          result)
      (setf result (parcl:do-symbols (symbol package :result)
                     (push symbol symbols)))
      (is (eq    :result result))
      (is (equal '()     symbols)))))

(test do-symbols.smoke ()
  "Smoke test for the `do-symbols' macro."
  (with-mock-package-constellation ((package "package"))
    (let* ((symbol1        (parcl:intern "foo" package))
           (symbol2        (parcl:intern "bar" package))
           (actual-symbols (list symbol1 symbol2))
           (symbols        '())
           result)
      (parcl:export symbol2 package)
      (setf result (parcl:do-symbols (symbol package symbols)
                     (push symbol symbols)))
      (is (eq        symbols        result))
      (is (set-equal actual-symbols symbols)))))

(test do-symbols.syntax-errors
  "Ensure that `do-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-symbols (s) . 1))))

;;; `do-all-symbols'

(test do-all-symbols.empty
  "Test `do-all-symbols' with an empty package system."
  (with-mock-package-constellation ()
    (let ((symbols '())
          result)
      (setf result (parcl:do-all-symbols (symbol :result)
                     (push symbol symbols)))
      (is (eq    :result result))
      (is (equal '()     symbols)))))

(test do-all-symbols.smoke
  "Smoke test for the `do-all-symbols' macro."
  (with-mock-package-constellation ((package1 "package1")
                                    (package2 "package2"))
    (let ((actual-symbols (list (parcl:intern "symbol1" package1)
                                (parcl:intern "symbol2" package2)))
          (symbols        '())
          result)
      (setf result (parcl:do-all-symbols (symbol symbols)
                     (push symbol symbols)))
      (is (eq        symbols        result))
      (is (set-equal actual-symbols symbols)))))

(test do-all-symbols.syntax-errors
  "Ensure that `do-all-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-all-symbols (s) . 1))))
