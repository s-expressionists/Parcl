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

  (define-restart-reporter (return-existing stream existing-package)
    (format stream "~@<Return the existing package ~S~@:>" existing-package))

  (define-restart-reporter (unintern stream conflicting-symbol using-package)
    (format stream "~@<Unintern ~S from ~S~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (shadow stream conflicting-symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (do-not-export stream symbol)
    (format stream "~@<Abort the EXPORT of ~s~@:>" symbol))

  (define-restart-reporter (make-old-shadowing stream conflicting-symbol using-package)
    (format stream "~@<Make ~S a shadowing symbol in ~S~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (make-new-shadowings stream symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            symbol using-package))

  (define-restart-reporter (do-not-export stream symbol)
    (format stream "~@<Abort the EXPORT of ~s~@:>" symbol))

  (define-restart-reporter (import stream symbol package)
    (format stream "~@<Import ~S into ~S~@:>" symbol package)))

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

  (define-reporter ((condition symbol-conflict) stream)
    ;; TODO: the condition should probably contain information about
    ;; the attempted operation
    (format stream "~@<The requested operation leads to a conflict between ~
                    the symbols ~{~S~^ and ~} in package ~S.~@:>"
            (conflicting-symbols condition) (package-error-package condition)))

  (define-reporter ((condition symbol-is-not-accessible-error) stream)
    (format stream "~@<The symbol ~S is not accessible in package ~S.~@:>"
            (inaccessible-symbol condition) (package-error-package condition)))

  (define-reporter ((condition package-is-not-used) stream)
    (format stream "~@<A package to be unused must be a used package, ~
                    but the package ~S is not used by the package ~S.~@:>"
            (package-to-unuse condition) (package-error-package condition)))

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
    (let ((package   (package-error-package condition))
          (conflicts (conflicts condition))
          (labels    (package-labels condition)))
      (pprint-logical-block (stream '())
        ;; TODO mention the operation
        (format stream "~@<The operation would introduce the following conflicts ~
                        in package ~A:~@:>~@:_~@:_"
                package)
        (report-conflicts stream conflicts package :labels labels)
        #++ (loop for (name . infos) in conflicts
              do (format stream "~@:_Symbol named ~S from packages ~{~A~^, ~}"
                         name (mapcar #'cdr infos)))))))


(defun report-conflicts (stream conflicts package &key labels)
  (let ((clusters (make-hash-table :test #'equal))
        (first?   t))
    (flet ((add-conflict (conflict)
             (let* ((infos    (cdr conflict))
                    (packages (mapcar #'cdr infos))
                    (sorted   (sort packages  #'string< :key (lambda (p) (package-name p)))) ; TODO: capture *client* or something
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
                                               for (symbol . nil) = (rassoc package infos
                                                                          :test #'eq)
                                               collect (prin1-to-string symbol))
                           collect (list* (prin1-to-string name) symbols))))
             #++ (destructuring-bind (name-length . conflicts) cluster
                   (setf conflicts (sort conflicts #'string< :key #'car)) ; TODO: properly
                   (format stream "~V<Name~> ~{~{~V@<Package ~S~>~}~^ ~}~%"
                           name-length (loop for package in packages
                                             collect (list 20 (package-name package))))
                   (loop for (name . infos) in conflicts
                         for symbols = (loop for package in packages
                                             for (name . nil) = (rassoc package infos
                                                                        :test #'eq)
                                             collect (list 20 name))
                         do (format stream "~V@<~S~> ~{~{~VS~}~^ ~}~%"
                                    name-length name symbols)))))
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
