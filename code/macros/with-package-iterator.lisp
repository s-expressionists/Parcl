(cl:in-package #:parcl)

;;; TODO: should this be a middle generic function?
(defun make-closure (package-list symbol-types)
  (when (or (null package-list) (null symbol-types))
    (return-from make-closure (lambda () nil)))
  (let ((client             *client*)
        (internal?          (member :internal symbol-types))
        (external?          (member :external symbol-types))
        (inherited?         (member :inherited symbol-types))
        (remaining-packages package-list)
        (symbol-entries     (make-array 0 :adjustable t :fill-pointer 0))
        (current-package    nil))
    (labels ((maybe-push-entry (symbol status)
               (when (ecase status
                       (:internal  internal?)
                       (:external  external?)
                       (:inherited inherited?))
                 (vector-push-extend status symbol-entries 2)
                 (vector-push        symbol symbol-entries)))
             (next-package ()
               (setf current-package (pop remaining-packages))
               (unless (null current-package)
                 (if inherited?
                     (parcl.middle::map-accessible-entries
                      client
                      (lambda (containing-package symbol export-status shadow-status)
                        (declare (ignore shadow-status))
                        (if (eq containing-package current-package)
                            (maybe-push-entry symbol export-status)
                            (maybe-push-entry symbol :inherited)))
                      current-package)
                     (parcl-low:map-symbol-entries
                      client (lambda (symbol export-status shadow-status)
                               (declare (ignore shadow-status))
                               (maybe-push-entry symbol export-status))
                      current-package))
                 t))
             (next-symbol ()
               (when (plusp (length symbol-entries))
                 (values (vector-pop symbol-entries)
                         (vector-pop symbol-entries))))
             (return-one ()
               (tagbody
                try-next-symbol
                  (multiple-value-bind (symbol status) (next-symbol)
                    (when (not (null status))
                      (return-from return-one
                        (values t symbol status current-package))))
                try-next-package
                  (when (next-package)
                    (go try-next-symbol)))))
      (next-package)
      #'return-one)))

(let* ((parcl:*client* (make-instance 'parcl.implementation.native:client))
       (thunk          (make-closure (list (parcl:find-package "CL-USER"))
                                     '(:internal :external :inherited))))
  (let ((cl:*package* (find-package '#:keyword)))
    (loop :for (ok? symbol status package) = (multiple-value-list (funcall thunk))
          :while ok?
          :count 1 :into count
          :do (format *trace-output* "~64S ~32A ~A~%"
                      symbol (package-name package) status)
          :finally (format *trace-output* "~:D symbol~:P~%" count))))

(cl:with-package-iterator (thunk (list (cl:find-package "CL-USER"))
                                 :internal :external :inherited)
  (let ((cl:*package* (cl:find-package '#:keyword)))
    (loop :for (ok? symbol status package) = (multiple-value-list (thunk))
          :while ok?
          :count 1 :into count
          :do (format *trace-output* "~64S ~32A ~A~%"
                      symbol (cl:package-name package) status)
          :finally (format *trace-output* "~:D symbol~:P~%" count))))

#++ (clouseau:inspect (cl:find-package "CL-USER"))

(defmacro with-package-iterator ((name package-list-form &rest symbol-types)
                                 &body body)
  ;; TODO: better errors. maybe via s-expression-syntax?
  (when (null symbol-types)
    (error 'macro-syntax-error :format-control "~@<At least one symbol-type must be supplied.~@:>"))
  (loop for object in symbol-types
        when (not (member object '(:internal :external :inherited)))
          do (error 'macro-syntax-error :format-control   "~@<~S is not a valid symbol type.~@:>"
                                        :format-arguments (list object)))
  (multiple-value-bind (declarations tags-and-statements)
      (ecclesia:separate-ordinary-body body)
   `(let ((closure (make-closure (package-list<-designator *client* ,package-list-form) ; TODO: make a runtime function for doing the coercion
                                 '(,@symbol-types))))
      ,@declarations
      (flet ((,name () (funcall closure)))
        ,@body))))
