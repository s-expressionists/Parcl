(cl:in-package #:parcl-class)

(defmethod parcl:map-symbols (client package function)
  (let ((visited 
          (loop for entry in (symbol-entries package)
                for symbol = (entry-symbol entry)
                do (funcall function symbol)
                collect symbol)))
    (loop for package in (use-list package)
          do (parcl:map-external-symbols
              client package
              (lambda (symbol)
                (unless (member symbol visited
                                :test (lambda (symbol1 symbol2)
                                        (parcl:symbol-names-equal
                                         client symbol1 symbol2)))
                  (funcall function symbol)
                  (push symbol visited)))))))
