(cl:defpackage #:parcl.test
  (:use
   #:cl)

  (:local-nicknames
   (#:a   #:alexandria)
   (#:low #:parcl-low))

  (:import-from #:fiveam
   #:def-suite
   #:in-suite
   #:test
   #:is
   #:is-true
   #:is-false
   #:signals
   #:finishes)

  (:export
   #:run-tests))

(cl:in-package #:parcl.test)

(def-suite :parcl)

(defun run-tests ()
  (fiveam:run! :parcl))
