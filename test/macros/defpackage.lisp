(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(test defpackage.smoke
  (with-mock-package-system ()
    (parcl:defpackage #1="FOO")
    (let ((package (parcl:find-package #1#)))
      (is-true (parcl:packagep package))
      (is (equal (parcl:package-name package) #1#)))))

(test defpackage.syntax-errors
  (signals parcl::macro-syntax-error
    (macroexpand '(parcl:defpackage 1))))

(test defpackage.runtime-errors
  )

(test defpackage.variance
  )

#++ (let ((*client* (make-instance 'parcl.implementation.native:client)))
      (mapc #'delete-package '("FOO" "BAR"))
      (describe (defpackage bar (:intern #:x "Y") (:export "BAR" "FEZ")))
      (describe (defpackage foo
                  (:local-nicknames ("A" "B"))
                  (:use cl "BAR")
                  (:export "BAR" :foo #:baz) ; (:export #\d)
                  (:intern "A" :b) (:intern #:c #\d)
                  (:shadow #:hi :yo)
                  (:shadowing-import-from #:bar #:x "Y"))))

#++ (progn
  (mapc #'cl:delete-package '("FOO" "BAR"))
  (describe (cl:defpackage bar (:intern #:x "Y") (:export "BAR" "FEZ")))
  (describe (cl:defpackage foo
              (:use cl "BAR")
              (:export "BAR" :foo #:baz) (:export #\d)
              (:intern "A" :b) (:intern #:c #\d)
              (:shadow #:hi :yo)
              (:shadowing-import-from #:bar #:x "Y"))))
