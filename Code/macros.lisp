(cl:in-package #:parcl)

(defmacro do-symbols
    ((symbol-variable
      &optional
        (package-designator-form '*package*)
        (result-form 'nil))
     &body body)
  (do-symbols-expander
    *client* symbol-variable package-designator-form result-form body))

(defmacro do-external-symbols
    ((symbol-variable
      &optional
        (package-designator-form '*package*)
        (result-form 'nil))
     &body body)
  (do-external-symbols-expander
    *client* symbol-variable package-designator-form result-form body))
