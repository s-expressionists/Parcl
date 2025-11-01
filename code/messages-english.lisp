(cl:in-package #:parcl)

;;; Recovery strategy descriptions

(macrolet ((define-restart-reporter ((restart-name
                                      &optional (stream-var 'stream)
                                      &rest parameters)
                                     &body body)
             `(defmethod acclimation:report-function
                  ((restart (eql ',restart-name))
                   (language acclimation:english))
                ,(if (typep body '(cons string null))
                     `(lambda (,stream-var)
                        (apply #'format ,(first body) ,stream-var))
                     `(lambda (,stream-var ,@parameters)
                        ,@body)))))

  (define-restart-reporter (do-nothing stream operation)
    (format stream "~@<Finish the ~A operation without actually doing ~
                    anything~@:>"
            operation))

  (define-restart-reporter (abort-operation stream operation)
    (format stream "~@<Abort the ~A operation~@:>" operation))

  (define-restart-reporter (return-existing stream existing-package)
    (format stream "~@<Return the existing package ~S~@:>" existing-package))

  (define-restart-reporter (unintern stream conflicting-symbol using-package)
    (format stream "~@<Unintern ~S from ~S~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (shadow stream conflicting-symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (make-old-shadowing stream conflicting-symbol using-package)
    (format stream "~@<Make ~S a shadowing symbol in ~S~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (make-new-shadowing stream symbol using-package)
    (format stream "~@<Make ~S a shadowing symbol in ~S~@:>"
            symbol using-package))

  (define-restart-reporter (do-not-export stream symbol)
    (format stream "~@<Abort the EXPORT of ~s~@:>" symbol))

  (define-restart-reporter (import stream symbol package)
    (format stream "~@<Import ~S into ~S~@:>" symbol package))

  (define-restart-reporter (keep-old-nicknamed-package stream nickname package)
    (format stream "~@<Keep the nickname ~S associated with the package ~A~@:>"
            nickname package))

  (define-restart-reporter (use-new-nicknamed-package stream nickname package)
    (format stream "~@<Associate the nickname ~S with the package ~A~@:>"
            nickname package))

  (define-restart-reporter (unuse-package stream used-package using-package)
    (format stream "~@<Make package ~A no longer use package ~A.~@:>"
            using-package  used-package)))

(macrolet ((define-reporter (((condition-var condition-specializer) stream-var
                              &optional (language-var 'language))
                             &body body)
             `(defmethod acclimation:report-condition
                ((,condition-var ,condition-specializer)
                 ,stream-var
                 (,language-var acclimation:english))
                ,@body)))

  ;; Symbol related conditions

  (define-reporter ((condition symbol-name-must-be-string) stream)
    (format stream "~@<Symbol name must be a string, but the ~
                    following was given instead: ~S.~@:>"
            (type-error-datum condition)))

  (define-reporter ((condition symbols-must-be-designator-for-list-of-symbols)
                    stream)
    (format stream "~@<Argument must be a designator for a list of symbols, ~
                    but the following was found instead: ~
                    ~S.~@:>"
            (symbols condition)))

  ;; Package related conditions

  (define-reporter ((condition package-name-occupied-error) stream)
    (format stream "~@<The package name ~S is already occupied by the ~
                    package ~S.~@:>"
            (new-name condition) (existing-package condition)))

  (define-reporter ((condition new-name-occupied-error) stream)
    (format stream "~@<The new name ~S for package ~S is already occupied by ~
                    the package ~S.~@:>"
            (new-name condition)
            (package-error-package condition)
            (existing-package condition)))

  (define-reporter ((condition package-does-not-exist-error) stream)
    (format stream "~@<~S does not designate a package.~@:>"
            (package-error-package condition)))

  (define-reporter ((condition package-has-been-deleted-error) stream)
    (format stream "~@<The package ~S has been deleted and cannot be operated on.~@:>"
            (package-error-package condition)))

  (define-reporter ((condition package-in-use-error) stream)
    (format stream "~@<The package ~A is used by package ~A.~@:>"
            (package-error-package condition)
            (used-by condition)))

  (define-reporter ((condition nickname-refers-to-different-package-error) stream)
    (format stream "~@<Attempt to add the package-local nickname:~@
                    ~s~@
                    to refer to the package:~@
                    ~s~@
                    in the package:~@
                    ~s,~@
                    but that nickname already refers to a different ~
                    package.~@:>"
            (nickname condition)
            (nicknamed-package condition)
            (package-error-package condition)))

  ;; Conditions related to package-symbol relations

  (define-reporter ((condition symbol-conflicts-error) stream)
    ;; TODO: the condition should probably contain information about
    ;; the attempted operation
    (let ((package   (package-error-package condition))
          (conflicts (conflicts condition))
          (labels    (package-labels condition)))
      (pprint-logical-block (stream '())
        (format stream "~@<The operation on package ~A would introduce the ~
                        following conflicts:~@:>~@:_~@:_"
                package)
        (report-conflicts stream conflicts package :labels labels))))

  (define-reporter ((condition symbol-is-not-accessible-error) stream)
    (format stream "~@<The symbol ~S is not accessible in package ~S.~@:>"
            (inaccessible-symbol condition) (package-error-package condition)))

  (define-reporter ((condition unexport-forbidden-for-system-package-error) stream)
    (format stream "~@<Attempt to unexport symbol ~A from the system package ~
                    ~A.~@:>"
            (symbol-to-unexport condition) (package-error-package condition))))

(defun report-conflicts (stream conflicts package &key labels)
  (let ((clusters (make-hash-table :test #'equal))
        (first?   t))
    (flet ((add-conflict (conflict)
             (let* ((infos    (cdr conflict))
                    (packages (remove-duplicates (mapcar #'cdr infos) :test #'eq))
                    (sorted   (sort packages #'string< :key (lambda (p) (package-name p)))) ; TODO: capture *client* or something
                    (key      (if (find package sorted :test #'eq)
                                  (list* package (remove package packages :test #'eq :count 1))
                                  sorted)))
               (push conflict (gethash key clusters '()))))
           (report-cluster (packages conflicts)
             (if first?
                 (setf first? nil)
                 (format stream "~@:_~@:_"))
             (format-table
              stream
              (list* (list* "Name" (mapcar (lambda (a-package)
                                             (format nil "Package ~S~@[ (~A)~]"
                                                     (package-name a-package)
                                                     (cdr (assoc a-package labels :test #'eq))
                                                     )) ; TODO: capture *client* or extract names earlier
                                           packages))
                     (loop for (name . infos) in conflicts
                           for symbols = (loop for package in packages
                                               collect (with-output-to-string (stream)
                                                         (loop with first? = t
                                                               for (symbol . info-package) in infos
                                                               when (eq info-package package)
                                                                 do (if first?
                                                                        (setf first? nil)
                                                                        (write-string ", " stream))
                                                                    (prin1 symbol stream))))
                           collect (list* (prin1-to-string name) symbols))))))
      (mapc #'add-conflict conflicts)
      (maphash #'report-cluster clusters))))

(defun format-table (stream rows)
  (unless (null rows)
    (let ((widths (make-array (length (first rows)) :initial-element 0)))
      (loop for row in rows
            do (loop for cell in row
                     for i from 0
                     ;; TODO a:maxf
                     do (setf (aref widths i) (max (aref widths i) (length cell)))))
      (loop for first? = t then nil
            for row in rows
            do (format stream "~:[~@:_~;~]~{~V@<~A~>~^  ~}"
                       first?
                       (loop for cell in row
                             for i from 0
                             ;; TODO a:maxf
                             collect (aref widths i) collect cell))))))
