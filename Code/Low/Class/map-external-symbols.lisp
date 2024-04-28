(cl:in-package #:parcl-low-class)

(defmethod parcl-low:map-external-symbols (client package function)
  (loop for entry in (symbol-entries package)
        when (or (eq (entry-status entry) :external)
                 (eq (entry-status entry) :external-shadowing))
          do (funcall function (entry-symbol entry))))
