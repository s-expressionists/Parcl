(cl:in-package #:parcl)

(defgeneric find-package (package-designator))

;;; Restart reports

(defun report-restart (restart-name stream &rest arguments)
  (let* ((language (acclimation:language acclimation:*locale*))
         (function (acclimation:report-function restart-name language)))
    (apply function stream arguments)))
