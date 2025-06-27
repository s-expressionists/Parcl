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

  (define-restart-reporter (unintern stream conflicting-symbol using-package)
    (format stream "~@<Unintern ~s from ~s~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (shadow stream conflicting-symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (do-not-export stream symbol)
    (format stream "~@<Abort the EXPORT of ~s~@:>" symbol))

  (define-restart-reporter (make-old-shadowing stream conflicting-symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            conflicting-symbol using-package))

  (define-restart-reporter (make-new-shadowings stream symbol using-package)
    (format stream "~@<Make ~s a shadowing symbol in ~s~@:>"
            symbol using-package))

  (define-restart-reporter (do-not-export stream symbol)
    (format stream "~@<Abort the EXPORT of ~s~@:>" symbol))

  (define-restart-reporter (import stream symbol package)
    (format stream "~@<Import ~s into ~s~@:>" symbol package)))

(macrolet ((define-reporter (((condition-var condition-specializer) stream-var
                              &optional (language-var 'language))
                             &body body)
             `(defmethod acclimation:report-condition
                ((,condition-var ,condition-specializer)
                 ,stream-var
                 (,language-var acclimation:english))
                ,@body)))

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

  (define-reporter ((condition symbol-conflict) stream)
    ;; TODO: the condition should probably contain information about
    ;; the attempted operation
    (format stream "~@<The requested operation leads to a conflict between ~
                    the symbols ~{~S~^ and ~} in package ~S.~@:>"
            (conflicting-symbols condition) (package-error-package condition)))

  (define-reporter ((condition symbol-is-not-accessible) stream)
    (format stream "~@<The symbol ~S is not accessible in package ~S.~@:>"
            (inaccessible-symbol condition) (package-error-package condition)))

  (define-reporter ((condition package-is-not-used) stream)
    (format stream "~@<A package to be unused must be a used package, ~
                    but the package ~S is not used by the package ~S.~@:>"
            (package-to-unuse condition) (package-error-package condition)))

  (define-reporter ((condition nickname-refers-to-different-package) stream)
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
            (package-error-package condition))))
