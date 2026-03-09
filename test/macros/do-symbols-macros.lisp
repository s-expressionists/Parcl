(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(test do-external-symbols.empty
  (with-mock-package-constellation ((package "package"))
    (let ((symbols '())
          result)
      (setf result (parcl:do-external-symbols (symbol package :result)
                     (push symbol symbols)))
      (is (eq    :result result))
      (is (equal '()     symbols)))))

(test do-external-symbols.smoke
  (with-mock-package-constellation ((package "package"))
    (let ((symbol1 (parcl:intern "foo" package))
          (symbol2 (parcl:intern "bar" package))
          (symbols '())
          result)
      (declare (ignore symbol1))
      (parcl:export symbol2 package)
      (setf result (parcl:do-external-symbols (symbol package :result)
                     (push symbol symbols)))
      (is (eq    :result        result))
      (is (equal (list symbol2) symbols)))))

(test do-external-symbols.syntax-errors
  "Ensure that `do-external-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-external-symbols (s) . 1))))

(test do-symbols.syntax-errors
  "Ensure that `do-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-symbols (s) . 1))))

(test do-all-symbols.empty
  (with-mock-package-constellation ()
    (let ((symbols '())
          result)
      (setf result (parcl:do-all-symbols (symbol symbols)
                     (push symbol symbols)))
      (is (eq symbols result))
      (is (equal '() result)))))

(test do-all-symbols.smoke
  (with-mock-package-constellation ((package1 "package1")
                                    (package2 "package2"))
    (let ((actual-symbols (list (parcl:intern "symbol1" package1)
                                (parcl:intern "symbol2" package2)))
          (symbols        '())
          result)
      (setf result (parcl:do-all-symbols (symbol symbols)
                     (push symbol symbols)))
      (is (eq symbols result))
      (is (set-equal actual-symbols result)))))

(test do-all-symbols.syntax-errors
  "Ensure that `do-all-symbols' signals appropriate errors for
syntax errors in the macro invocation."
  ;; TODO: test errors in binding, argument and result form
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:do-all-symbols (s) . 1))))
