(cl:in-package #:parcl)

;;; Runtime

;;; TODO: should this be a middle generic function?
(defun %make-symbol-iterator (client package-list symbol-types)
  (let ((internal?          (member :internal symbol-types))
        (external?          (member :external symbol-types))
        (inherited?         (member :inherited symbol-types))
        (remaining-packages package-list)
        (current-package    nil)
        (symbol-entries     (make-array 0 :adjustable t :fill-pointer 0)))
    (labels ((maybe-push-entry (symbol status)
               (when (ecase status
                       (:internal  internal?)
                       (:external  external?)
                       (:inherited inherited?))
                 (vector-push-extend status symbol-entries 2)
                 (vector-push        symbol symbol-entries)))
             (next-package ()
               (setf current-package (pop remaining-packages))
               (cond ((null current-package)
                      (setf remaining-packages :end)
                      nil)
                     (inherited?
                      (parcl.middle::map-accessible-entries
                       client
                       (lambda (containing-package symbol export-status shadow-status)
                         (declare (ignore shadow-status))
                         (if (eq containing-package current-package)
                             (maybe-push-entry symbol export-status)
                             (maybe-push-entry symbol :inherited)))
                       current-package)
                      t)
                     (t
                      (parcl.low:map-symbol-entries
                       client (lambda (symbol export-status shadow-status)
                                (declare (ignore shadow-status))
                                (maybe-push-entry symbol export-status))
                       current-package)
                      t)))
             (next-symbol ()
               (tagbody
                try-next-symbol
                  (when (plusp (length symbol-entries))
                    (return-from next-symbol
                      (values t
                              (vector-pop symbol-entries)
                              (vector-pop symbol-entries)
                              current-package)))
                try-next-package
                  (cond ((eq remaining-packages :end)
                         (error 'iterator-at-end-error))
                        ((next-package)
                         (go try-next-symbol))
                        (t
                         nil)))))
      #'next-symbol)))

(defun make-symbol-iterator (package-designators symbol-types)
  (let* ((client   *client*)
         (packages (package-list<-designator client package-designators)))
    (%make-symbol-iterator client packages symbol-types)))

;;; Macro

(defun expand-with-package-iterator
    (name package-list-form symbol-types declarations tags-and-statements)
  (let ((iterator (gensym "ITERATOR")))
    `(let ((,iterator (make-symbol-iterator ,package-list-form
                                            '(,@symbol-types))))
       (macrolet ((,name () `(funcall ,',iterator)))
         ,@declarations
         ,@tags-and-statements))))

(defmacro with-package-iterator ((&whole arguments
                                  name package-list-form &rest symbol-types)
                                 &body body)
  ;; TODO: better errors. maybe via s-expression-syntax?
  (when (null symbol-types)
    (error 'macro-syntax-error
           :format-control "~@<At least one symbol-type must be supplied.~@:>"
           :expression     arguments))
  (loop for object in symbol-types
        when (not (member object '(:internal :external :inherited)))
          do (error 'macro-syntax-error
                    :format-control   "~@<~S is not a valid symbol type.~@:>"
                    :format-arguments (list object)
                    :expression       object))
  (multiple-value-bind (declarations tags-and-statements)
      (ecclesia:separate-ordinary-body body)
    (expand-with-package-iterator
     name package-list-form symbol-types declarations tags-and-statements)))

#+TODO (define-macro with-package-iterator ((name package-list-form &rest symbol-types)
                                     &body body)
    ast
  (let ((name                (ico:name-ast ast))
        (package-list        (ico:package-list-ast ast))
        (symbol-types        (ico:symbol-types-ast ast))
        (declarations        (ico:declaration-asts ast))
        (tags-and-statements (ico:tagbody-segment-ast ast)))
    (break "~S" name)
    (expand-with-package-iterator
     name package-list-form symbol-types declarations tags-and-statements)))
