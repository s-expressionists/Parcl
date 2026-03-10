(cl:defpackage #:parcl.ansi-test
  (:use
   #:cl))

(cl:in-package #:parcl.ansi-test)

(defvar *tests*
  '("DEFPACKAGE"
    "DELETE-PACKAGE"
    "DO-ALL-SYMBOLS"
    "DO-EXTERNAL-SYMBOLS"
    "DO-SYMBOLS"
    "EXPORT"
    "FIND-ALL-SYMBOLS"
    "FIND-PACKAGE"
    "FIND-SYMBOL"
    "IMPORT"
    "IN-PACKAGE"
    "INTERN"
    "KEYWORD"
    "LIST-ALL-PACKAGES"
    "LOAD"
    "MAKE-PACKAGE"
    "PACKAGE-ERROR"
    "PACKAGE-ERROR-PACKAGE"
    "PACKAGE-NAME"
    "PACKAGE-NICKNAMES"
    "PACKAGEP"
    "PACKAGE-SHADOWING-SYMBOLS"
    "PACKAGE-USED-BY-LIST"
    "PACKAGE-USE-LIST"
    "RENAME-PACKAGE"
    "SHADOWING-IMPORT"
    "SHADOW"
    "UNEXPORT"
    "UNINTERN"
    "UNUSE-PACKAGE"
    "USE-PACKAGE"
    "WITH-PACKAGE-ITERATOR"))

(defvar *extrinsic-symbols*
  '(;; Variable
    parcl:*package*
    ;; Conditions
    parcl:package-error
    parcl:package-error-package
    ;; Symbol functions
    parcl:symbolp
    parcl:symbol-name
    parcl:symbol-package
    parcl:make-symbol                   ; TODO: grouped here
    parcl:keywordp
    ;; Package functions
    parcl:packagep
    parcl:package-name
    parcl:package-nicknames
    parcl:package-use-list
    parcl:package-used-by-list
    parcl:package-shadowing-symbols
    ;; Package-package relation functions
    parcl:use-package
    parcl:unuse-package
    ;; Package-symbol relation functions
    parcl:find-symbol
    parcl:intern
    parcl:unintern
    parcl:import
    parcl:export
    parcl:unexport
    parcl:shadow
    parcl:shadowing-import
    ;; Environment functions
    parcl:find-all-symbols
    parcl:list-all-packages
    parcl:find-package
    parcl:make-package
    parcl:delete-package
    parcl:rename-package
    ;; Macros
    parcl:in-package
    parcl:defpackage
    parcl:with-package-iterator
    parcl:do-symbols
    parcl:do-external-symbols
    parcl:do-all-symbols))

(defun test (&rest args &key exit &allow-other-keys)
  (setf args (remprop :exit args))
  (let* ((system            (asdf:find-system "parcl-extrinsic/ansi-test"))
         (ansi-directory    (merge-pathnames
                             (make-pathname :directory '(:relative
                                                         "dependencies"
                                                         "ansi-test"))
                             (asdf:component-pathname system)))
         (expected-failures (asdf:component-pathname
                             (asdf:find-component
                              system '("test" "expected-failures.sexp"))))
         (parcl:*client*    (make-instance 'parcl.test::mock-client)))
    ;; Populate the mock package system with the necessary packages
    ;; and symbols.
    (let ((keyword          (parcl:make-package "KEYWORD"))
          (common-lisp      (parcl:make-package "COMMON-LISP"
                                                :nicknames '("CL")))
          (common-lisp-user (parcl:make-package "COMMON-LISP-USER"
                                                :nicknames '("CL-USER")))
          (regression-test  (parcl:make-package "REGRESSION-TEST"
                                                :nicknames '("RT")))
          (cl-test          (parcl:make-package "CL-TEST" :use '("CL"))))
      (cl:do-external-symbols (symbol '#:keyword)
        (let ((new-symbol (parcl:intern (cl:symbol-name symbol) keyword)))
          (parcl:export new-symbol keyword)))
      (cl:do-external-symbols (symbol '#:common-lisp)
        (let ((new-symbol (parcl:intern (cl:symbol-name symbol) common-lisp)))
          (parcl:export new-symbol common-lisp)))
      ;; Run tests.
      (let ((parcl:*package* cl-test))
        ;; Force recompilation of files so that the package system
        ;; gets put into the correct state.
        (setf cl-user::*compiled-and-loaded-files* '())
        (apply #'ansi-test-harness:ansi-test
               :directory         ansi-directory
               :expected-failures expected-failures
               :extrinsic-symbols *extrinsic-symbols*
               :tests             *tests*
               :skip-sync         t
               args)))))

(test)

;;;; Debugging

(defun call-with-ansi-test-setup (continuation)
  (let* ((parcl:*client*   (make-instance 'parcl.test::mock-client))
         (keyword          (parcl:make-package "KEYWORD"))
         (common-lisp      (parcl:make-package "COMMON-LISP"
                                               :nicknames '("CL")))
         (common-lisp-user (parcl:make-package "COMMON-LISP-USER"
                                               :nicknames '("CL-USER")))
         (regression-test  (parcl:make-package "REGRESSION-TEST" :nicknames '("RT")))
         (cl-test          (parcl:make-package "CL-TEST" :use '("CL"))))
    (cl:do-external-symbols (symbol '#:keyword)
      (let ((new-symbol (parcl:intern (cl:symbol-name symbol) keyword)))
        (parcl:export new-symbol keyword)))
    (cl:do-external-symbols (symbol '#:common-lisp)
      (let ((new-symbol (parcl:intern (cl:symbol-name symbol) common-lisp)))
        (parcl:export new-symbol common-lisp)))
    (funcall continuation)))


(defun sort-symbols (sl)
  (sort (copy-list sl)
        #'(lambda (x y)
            (or
             (string< (symbol-name x)
                      (symbol-name y))
             (and (string= (symbol-name x)
                           (symbol-name y))
                  (string< (package-name (symbol-package x))
                           (package-name (symbol-package y))))))))

(defun collect-symbols (pkg)
  (remove-duplicates
   (sort-symbols
    (let ((all nil))
      (do-symbols (x pkg all) (push x all))))))

(defun collect-external-symbols (pkg)
  (remove-duplicates
   (sort-symbols
    (let ((all nil))
      (do-external-symbols (x pkg all) (push x all))))))

(call-with-ansi-test-setup
 (lambda ()
   (set-difference (collect-symbols "KEYWORD")
                   (intersection (collect-external-symbols "KEYWORD")
                                 (collect-symbols "KEYWORD")))))


(call-with-ansi-test-setup
 (lambda ()
   (do-symbols (s "KEYWORD" t)
     (unless (keywordp s)
       (return (list s nil))))))
