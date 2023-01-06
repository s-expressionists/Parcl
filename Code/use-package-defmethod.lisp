(cl:in-package #:parcl)

(defun check-for-conflict (client package symbol)
  (check-for-conflict-with-present client package symbol)
  (loop for used-package in (use-list package)
        do (check-for-conflict-with-inherited
            client package symbol used-package)))))

(defmethod use-package (client package package-to-use)
  (loop for symbol in (external-symbols-list client package-to-user)
        do (check-for-conflict client package symbol))
  (push package-to-use (use-list client package)))
