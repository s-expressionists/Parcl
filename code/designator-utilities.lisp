(cl:in-package #:parcl)

;;; Convenience functions

(defun check-package-designator (client package-designator)
  (if (parcl.low:packagep client package-designator)
      (values package-designator                             t)
      (values (string<-designator client package-designator) nil)))

(defun find-package-or-error (client package-designator)
  (if (parcl.low:packagep client package-designator)
      package-designator
      (let* ((name    (string<-designator client package-designator))
             (package (parcl.middle:find-package-using-package
                       client (if (boundp '*package*) *package* nil) name)))
        (when (null package)
          (restart-case
              (error 'package-does-not-exist-error :package package-designator)
            (continue ()
              :report "Do not perform the operation"))) ; TODO: report; should this mention the operation?
        package)))

(defun find-undeleted-package-or-error (client package-designator)
  (let ((package (find-package-or-error client package-designator)))
    (when (null (parcl.low:name client package))
      (error 'package-has-been-deleted-error :package package))
    package))

;;;; Designators

;;; String

(defun string<-designator (client string-designator)
  (cond ((characterp string-designator)
         (string string-designator))
        ((stringp string-designator)
         string-designator)
        ((parcl.low:symbolp client string-designator)
         (parcl.low:symbol-name client string-designator))
        (t
         ;; TODO: dedicated error?
         ;; TODO: expected type
         (error 'type-error :datum string-designator :expected-type 'string))))

;; TODO: what should we do about repeated entries?
(defun string-list<-designator-list (client string-designator-list)
  (mapcar (lambda (string-designator)
            (string<-designator client string-designator))
          string-designator-list))

(defun string-list<-designator (client string-list-designator)
  (if (listp string-list-designator)
      (string-list<-designator-list client string-list-designator)
      (list (string string-list-designator))))

;;; Symbol

(defun check-symbol (client symbol)
  (unless (parcl.low:symbolp client symbol)
    (error 'type-error :datum symbol :expected-type 'symbol)) ; TODO: this is not the correct type
  symbol)

(defun symbol-list<-designator-list (client symbol-designator-list)
  ;; TODO(jmoringe): (every (lambda (symbol-designator) (or (stringp symbol-designator) (parcl.low:symbolp symbol-designator))
  (unless (and (ecclesia:proper-list-p symbol-designator-list)
               (every (lambda (object) (parcl.low:symbolp client object)) ; TODO: `check-symbol' individually?
                      symbol-designator-list))
    (error 'symbols-must-be-designator-for-list-of-symbols ; TODO: type-error?
           :symbols symbol-designator-list))
  symbol-designator-list)

(defun symbol-list<-designator (client symbol-list-designator)
  (if (listp symbol-list-designator) ; TODO: what does `nil' designate?
      (symbol-list<-designator-list client symbol-list-designator)
      (list (check-symbol client symbol-list-designator))))

;;; Package

(defun package-name<-designator (client package-designator)
  (if (parcl.low:packagep client package-designator)
      (parcl.low:name client package-designator)
      (string<-designator client package-designator)))

(defun package-list<-designator-list (client package-designator-list)
  (mapcar (lambda (designator)
            (find-undeleted-package-or-error client designator))
          package-designator-list))

(defun package-list<-designator (client package-list-designator)
  (if (listp package-list-designator)
      (package-list<-designator-list client package-list-designator)
      (list (find-undeleted-package-or-error client package-list-designator))))

;; TODO: shorter name? maybe with-<something>-bindings?
(defmacro with-client-and-resolved-designators ((client-var &rest bindings)
                                                &body body)
  (flet ((expand-binding (binding)
           (destructuring-bind (names designator-type) binding
             (let ((resolver
                     (ecase designator-type
                       ;; String
                       (string-designator        'string<-designator)
                       (string-designator-list   'string-list<-designator-list)
                       (string-list-designator   'string-list<-designator)
                       ;; Symbol
                       (symbol                   'check-symbol)
                       (symbol-designator        (error "todo"))
                       (symbol-designator-list   'symbol-list<-designator-list)
                       (symbol-list-designator   'symbol-list<-designator)
                       ;; Package
                       (package-name-designator  'package-name<-designator)
                       (package-designator       'find-undeleted-package-or-error)
                       (package-designator/weak  'find-package-or-error)
                       (package-designator/check 'check-package-designator)
                       (package-designator-list  'package-list<-designator-list) ; TODO: are these all used?
                       (package-list-designator  'package-list<-designator))))
               (if (consp names)
                   (destructuring-bind (variable-name parameter-name) names
                     `(,variable-name (,resolver ,client-var ,parameter-name)))
                   `(,names (,resolver ,client-var ,names)))))))
    `(let* ((,client-var *client*)
            ,@(mapcar #'expand-binding bindings))
       ,@body)))
