(cl:defpackage #:parcl.macros.test
  (:use
   #:cl)

  (:import-from #:fiveam
   #:def-suite
   #:in-suite
   #:test
   #:is
   #:is-true
   #:signals)

  (:import-from #:parcl.test
   #:set-equal
   #:set-equal/equal

   #:with-mock-package-system
   #:with-mock-package-constellation)

  (:export
   #:run-tests))

(cl:in-package #:parcl.macros.test)

(def-suite :parcl.macros)

(defun run-tests ()
  (fiveam:run! :parcl.macros))
