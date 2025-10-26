(cl:in-package #:parcl.middle)

(defmethod find-symbols ((client t) (name string))
  (loop for package in (packages client)
        for (symbol export-status) = (multiple-value-list
                                      (parcl.low:symbol-entry client name package))
        when (not (null export-status))
          collect symbol))
