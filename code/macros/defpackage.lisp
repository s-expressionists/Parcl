(cl:in-package #:parcl)

;;; Macro expander

(defun check-options-disjoint (name1 value1 name2 value2)
  (let ((intersection (intersection value1 value2 :test #'string=)))
    (when (not (null intersection))
      (let ((common (remove-duplicates intersection :test #'string=)))
        (error 'macro-syntax-error
               :format-control   "~@<The value~P ~{~S~^ and ~} ~2:*~[~;occurs~:;occur~] in both the ~S and the ~S ~S option.~@:>"
               :format-arguments (list (length common) common name1 name2 'defpackage)
               :expression       (first common))))))

(defun check-options-pairwise-disjoint (&rest names-and-options)
  (loop :for ((name1 value1) . rest) :on names-and-options
        :do (loop :for (name2 value2) :in rest
                  :do (check-options-disjoint name1 value1 name2 value2))))

;;; TODO: should we make this a generic function with a client parameter?
;;; TODO: share string designators, for symbols and packages, to (potentially) safe fasl space?
(defun emit-defpackage (name &rest args &key (nicknames             '()) ; TODO: find a consistent order for these options
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
   (list :shadow                shadow)
   (list :intern                intern)
   (list :import-from           (alexandria:mappend #'cdr import-from))
   (list :shadowing-import-from (alexandria:mappend #'cdr shadowing-import-from)))
  (check-options-disjoint :intern intern :export export)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (parcl.middle:ensure-package
      *client* ',name ,@(loop :for (key value) :on args :by #'cddr
                              :collect key :collect `',value))))

;;; Parsing

(defun strings<-designator-nodes (designator-nodes)
  (mapcar #'string<-designator-node designator-nodes))

(defun cons<-import-from-node (import-from-node)
  (let ((package-name (string<-designator-node
                       (architecture.builder-protocol:node-relation
                        **builder** '(:package . 1) import-from-node)))
        (symbol-names (strings<-designator-nodes
                       (architecture.builder-protocol:node-relation
                        **builder** '(:name . *) import-from-node))))
    (cons package-name symbol-names)))

(defun conses<-import-from-nodes (import-from-nodes)
  (mapcar #'cons<-import-from-node import-from-nodes))

;;; TODO: local-nicknames
(define-macro defpackage (name &rest options) node
  (let* ((name (string<-designator-node
                (architecture.builder-protocol:node-relation
                 **builder** '(:name . 1) node)))
         (args '()))
    (macrolet ((maybe-initarg (initarg relation transformation)
                 ;; TODO: we can't distinguish e.g. (:export) from no :export at all
                 `(let ((child (architecture.builder-protocol:node-relation
                                **builder** ,relation node)))
                    (unless (null child)
                      (push (,transformation child) args)
                      (push ,initarg                args)))))
      (maybe-initarg :nicknames     :nickname      strings<-designator-nodes)
      (maybe-initarg :shadow        :shadow        strings<-designator-nodes)
      (maybe-initarg :shadowing-import-from :shadowing-import-from conses<-import-from-nodes)
      (maybe-initarg :use           :use           strings<-designator-nodes)
      (maybe-initarg :import-from   :import-from   conses<-import-from-nodes)
      (maybe-initarg :intern        :intern        strings<-designator-nodes)
      (maybe-initarg :export        :export        strings<-designator-nodes)
      (maybe-initarg :size          :size          value<-literal-node)
      (maybe-initarg :documentation :documentation string<-designator-node))
    (apply #'emit-defpackage name args)))
