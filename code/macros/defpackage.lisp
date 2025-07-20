(cl:in-package #:parcl)

(sb-ext:add-package-local-nickname "ICO" "ICONOCLAST" "PARCL")

;;; Runtime support

(defun find-symbols (package-name &rest symbol-names)
  (loop with client = *client* ; TODO: pass in?
        with package = (find-undeleted-package-or-error client package-name) ; TODO(jmoringe): error
        for symbol-name in symbol-names
        for (symbol status) = (multiple-value-list
                               (find-symbol symbol-name package))
        if (not (null status))
          collect symbol
        else
          do (error "No symbol named ~S in package ~A" symbol-name package) ; TODO(jmoringe): proper error
        ))

;;; Used by (:export ...).  Ensures that SYMBOL-NAMES are present, via
;;; `intern' if not accessible and via `import' if inherited.
(defun ensure-symbols (package &rest symbol-names)
  (loop for symbol-name in symbol-names
        for (symbol status) = (multiple-value-list
                               (find-symbol symbol-name package))
        collect (case status
                  ((nil)
                   (intern symbol-name package))
                  (:inherited
                   (import symbol package)
                   symbol)
                  (t
                   symbol))))

(defun intern* (package &rest symbol-names)
  (loop with client = *client*
        for symbol-name in symbol-names
        do (parcl.middle:intern client package symbol-name)))

;; runtime effect of defpackage; defined as a function to minimize code size of defpackage expansion
#++ (defun define-package )

;;; Macro expander

(defun check-options-disjoint (name1 value1 name2 value2) ; TODO: pass source?
  (let ((intersection (intersection value1 value2 :test #'string=)))
    (when (not (null intersection))
      (let ((common (remove-duplicates intersection :test #'string=)))
        (error 'macro-syntax-error :format-control   "~@<The value~P ~{~S~^ and ~} occur in both the ~S and the ~S ~S option.~@:>"
                                   :format-arguments (list (length common) common name1 name2 'defpackage))))))

(defun check-options-pairwise-disjoint (&rest names-and-options)
  (loop for ((name1 . value1) . rest) on names-and-options
        do (loop for (name2 . value2) in rest
                 do (check-options-disjoint name1 value1 name2 value2))))

(defun expand-defpackage (name &key (nicknames             '())
                                    (shadow                '())
                                    (shadowing-import-from '())
                                    (use                   '())
                                    (import-from           '())
                                    (intern                '())
                                    (export                '())
                                    (documentation         nil))
  ;; From the `defpackage' entry in the specification: "The collection
  ;; of symbol-name arguments given to the options `:shadow',
  ;; `:intern', `:import-from', and `:shadowing-import-from' must all
  ;; be disjoint; additionally, the symbol-name arguments given to
  ;; `:export' and `:intern' must be disjoint.  Disjoint in this
  ;; context is defined as no two of the symbol-names being `string='
  ;; with each other. If either condition is violated, an error of
  ;; type `program-error' should be signaled."
  (check-options-pairwise-disjoint
   (cons :shadow                shadow)
   (cons :intern                intern)
   (cons :import-from           (alexandria:mappend #'cdr import-from))
   (cons :shadowing-import-from (alexandria:mappend #'cdr shadowing-import-from)))
  (check-options-disjoint :intern intern :export export)

  (let ((package (gensym "PACKAGE"))) ; TODO: no need for `gensym' since user code can never witness the binding
    `(let ((,package (or (find-package ',name) ; TODO: what if NAME matches a local nickname within the current package?
                         (make-package ',name))))
       ;; TODO: make an `update-package' function
       (rename-package ,package ,name '(,@nicknames))
       ;; The order of operations is given in the specification entry
       ;; for `defpackage':
       ;; 1. `:shadow' and `:shadowing-import-from'
       ,@(when (not (null shadow))
           `((shadow '(,@shadow) ,package)))
       ,@(loop for (from-package . names) in shadowing-import-from
               collect `(shadowing-import (find-symbols ,from-package ,@names) ,package))
       ;; 2. `:use'
       ,@(when (not (null use))
           `((use-package '(,@use) ,package)))
       ;; 3. `:import-from' and `:intern'
       ,@(loop for (from-package . names) in import-from
               collect `(import (find-symbols ,from-package ,@names) ,package))
       ,@(when (not (null intern))
           `((intern* ,package ,@intern)))
       ;; 4. `:export'
       ,@(when (not (null export))
           `((export (ensure-symbols ,package ,@export) ,package)))
       (setf (parcl-low:documentation *client* ,package) ,documentation)
       ,package)))

;;; Parsing

(defun strings<-designator-asts (designator-asts)
  (mapcar #'ico:designated-string designator-asts))

(defun cons<-import-from-asts (import-from-ast)
  (let ((package-name (ico:designated-string (ico:package-name-ast import-from-ast)))
        (symbol-names (strings<-designator-asts (ico:name-asts import-from-ast))))
   (cons package-name symbol-names)))
#++(defun find-symbols-form<-import-ast (import-ast)
  )

;;; TODO: share string designators to (potentially) safe fasl space
(defmacro defpackage (&whole form name &rest options)
  (declare (ignore name options))
  (let* ((ast                   (parse-defpackage form))
         (name                  (ico:designated-string (ico:name-ast ast)))
         (nicknames             (strings<-designator-asts (ico:nickname-asts ast)))
         (shadow                (strings<-designator-asts (ico:shadow-asts ast)))
         (shadowing-import-from (mapcar #'cons<-import-from-asts
                                        (ico:shadowing-import-from-asts ast)))
         (use                   (strings<-designator-asts (ico:use-asts ast)))
         (import-from           (mapcar #'cons<-import-from-asts
                                        (ico:import-from-asts ast)))
         (intern                (strings<-designator-asts (ico:intern-asts ast)))
         (export                (strings<-designator-asts (ico:export-asts ast)))
         (documentation         (alexandria:when-let ((documentation (ico:documentation-ast ast)))
                                  (ico:%string documentation))))
    (expand-defpackage name :nicknames             nicknames
                            :shadow                shadow
                            :shadowing-import-from shadowing-import-from
                            :use                   use
                            :import-from           import-from
                            :intern                intern
                            :export                export
                            :documentation         documentation)))

#++ (let ((*client* (make-instance 'parcl.implementation.native:client)))
  (mapc #'delete-package '("FOO" "BAR"))
  (describe (defpackage bar (:intern #:x "Y") (:export "BAR" "FEZ")))
  (describe (defpackage foo
              (:use cl "BAR")
              (:export "BAR" :foo #:baz) (:export #\d)
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
