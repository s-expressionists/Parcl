(cl:in-package #:parcl)

;;; Restart reports

(defun report-restart (restart-name stream &rest arguments)
  (let* ((language (acclimation:language acclimation:*locale*))
         (function (acclimation:report-function restart-name language)))
    (apply function stream arguments)))

;;; Convenience functions

(defun find-package-or-error (package-designator)
  (let ((package (find-package package-designator)))
    (when (null package) ; TODO(jmoringe): should this be recoverable?
      (error 'package-does-not-exist-error :package package-designator))
    package))
