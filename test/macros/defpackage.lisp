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


;;;

(when nil
  (export (mapcar (alexandria:rcurry #'intern "CL") '("FLOOR" "ABS")) "CL")
  #++(defpackage "bar"
    (:nicknames "bar-nick")
    (:nicknames "bar-nick2")

    (:import-from #:cl #:floor #:abs)

    (:use "COMMON-LISP")

    (:intern "hi" #:what)
    (:export "hihi")
    )

  (progn
    (defpackage "foo"
                                        ; (:nicknames "foo-nick")
                                        ; (:nicknames "foo-nick2")
      (:nicknames )

      ; (:import-from #:cl #:hi #:hihi)

                                        ; (:use "COMMON-LISP")
      (:use )

      (:intern "hi" #:what)
      (:export "hihi")
      )
    (use-package '() "foo")
    (print (package-nicknames "foo"))
    (describe (find-package "foo")))

  (progn
    (cl:defpackage "foo"
      (:nicknames "foo-nick")
      (:nicknames "foo-nick2")
                                        ; (:nicknames )

                                        ; (:use "CL")
                                        ; (:use )

                                        ; (:intern "S")
      (:intern)
      (:export "hi")
      )
    (cl:use-package '() "foo")
    (print (cl:package-nicknames "foo"))
    (describe (cl:find-package "foo"))))

(describe (cl:defpackage "test-package"
            ; (:use "CL-USER" "PARCL")
            ;; (:shadow "A" "B" "C")
            ;; (:export "D" "E" "F")
            ))
