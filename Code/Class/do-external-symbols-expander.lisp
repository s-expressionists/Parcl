(cl:in-package #:parcl-class)

(defmethod parcl:map-external-symbols (client package function)
  (loop for entry in (symbol-entries package)
        when (or (eq (entry-status entry) :external)
                 (eq (entry-status entry) :external-shadowing))
          do (funcall function symbol)))
