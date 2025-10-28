(cl:defpackage #:parcl.test
  (:use
   #:cl)

  (:local-nicknames
   (#:a   #:alexandria)
   (#:low #:parcl.low))

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

;;;

(defvar *high-tests* (make-hash-table :test #'eq))

(defun register-high-test (name body)
  (setf (gethash name *high-tests*) body))

(defmacro high-test (name-and-options &body body)
  (destructuring-bind (name &key (client-class 'mock-client))
      (a:ensure-list name-and-options)
    `(progn
       (register-high-test ',name ',body)
       (test ,name
         (let ((*client-maker* (lambda () (make-instance ',client-class))))
           ,@body)))))
