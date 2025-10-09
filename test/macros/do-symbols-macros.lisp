(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

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
