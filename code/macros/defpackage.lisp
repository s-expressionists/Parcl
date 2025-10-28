(cl:in-package #:parcl)

;;; Macro expander

(defun check-options-disjoint (name1 value1 name2 value2) ; TODO: pass source and do with-current-source-form?
  (let ((intersection (intersection value1 value2 :test #'string=)))
    (when (not (null intersection))
      (let ((common (remove-duplicates intersection :test #'string=)))
        (error 'macro-syntax-error :format-control   "~@<The value~P ~{~S~^ and ~} occur in both the ~S and the ~S ~S option.~@:>"
                                   :format-arguments (list (length common) common name1 name2 'defpackage))))))

(defun check-options-pairwise-disjoint (&rest names-and-options)
  (loop for ((name1 . value1) . rest) on names-and-options
        do (loop for (name2 . value2) in rest
                 do (check-options-disjoint name1 value1 name2 value2))))

;;; TODO: should we make this a generic function with a client parameter?
;;; TODO: share string designators, for symbols and packages, to (potentially) safe fasl space?
(defun expand-defpackage (name &rest args &key (nicknames             '()) ; TODO: find a consistent order for these options
                                               (shadow                '())
                                               (shadowing-import-from '())
                                               (use                   '())
                                               (import-from           '())
                                               (intern                '())
                                               (export                '())
                                               (size                  nil)
                                               (documentation         nil))
  ;; TODO: could just not list those and &allow-other-keys
  (declare (ignore nicknames use size documentation))
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
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (parcl.middle:ensure-package
      *client* ',name ,@(loop :for (key value) :on args :by #'cddr
                              :collect key :collect `',value))))

;;; Parsing

(defun strings<-designator-asts (designator-asts)
  (mapcar #'ico:designated-string designator-asts))

(defun cons<-import-from-ast (import-from-ast)
  (let ((package-name (ico:designated-string
                       (ico:package-name-ast import-from-ast)))
        (symbol-names (strings<-designator-asts
                       (ico:name-asts import-from-ast))))
    (cons package-name symbol-names)))

(defun conses<-import-from-asts (import-from-asts)
  (mapcar #'cons<-import-from-ast import-from-asts))

;;; TODO: local-nicknames
(define-macro defpackage (name &rest options) ast
  (let* ((name (ico:designated-string (ico:name-ast ast)))
         (args '()))
    (macrolet ((maybe-initarg (initarg reader transformation)
                 ;; TODO: we can't distinguish e.g. (:export) from no :export at all
                 `(alexandria:when-let ((child (,reader ast)))
                    (push (,transformation child) args)
                    (push ,initarg                args))))
      (maybe-initarg :nicknames     ico:nickname-asts     strings<-designator-asts)
      (maybe-initarg :shadow        ico:shadow-asts       strings<-designator-asts)
      (maybe-initarg :shadowing-import-from ico:shadowing-import-from-asts conses<-import-from-asts)
      (maybe-initarg :use           ico:use-asts          strings<-designator-asts)
      (maybe-initarg :import-from   ico:import-from-asts  conses<-import-from-asts)
      (maybe-initarg :intern        ico:intern-asts       strings<-designator-asts)
      (maybe-initarg :export        ico:export-asts       strings<-designator-asts)
      (maybe-initarg :size          ico:size-ast          ico:literal)
      (maybe-initarg :documentation ico:documentation-ast ico:%string))
    (apply #'expand-defpackage name args )))
