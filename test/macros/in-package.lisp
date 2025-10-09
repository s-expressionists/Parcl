(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(test in-package.smoke
  (with-mock-package-constellation ((nil #1="package1"))
    (parcl:in-package #1#)
    (is (eq parcl:*package* (parcl:find-package #1#)))))

(test in-package.syntax-errors
  (signals parcl::macro-syntax-error
    (macroexpand '(parcl:in-package 1)))
  (signals parcl::macro-syntax-error
    (macroexpand '(parcl:in-package "ok" 2))))

(test in-package.runtime-errors
  (with-mock-package-system ()
    (signals parcl:package-does-not-exist-error
      (parcl:in-package "does-not-exist"))))
