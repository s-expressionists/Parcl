(cl:in-package #:parcl)

(defmethod unexport (client package symbol)
  (let ((position (position symbol (external-symbols client package))))
    (if (null position)
        (restart-case 
            (error 'symbol-is-not-accessible
                   :package package
                   :symbol symbol)
          (continue ()
            :report
            (lambda (stream)
              (format stream "Continue"))
            (return-from unexport t)))
        (progn (remove-external-symbol client package symbol)
               t))))
