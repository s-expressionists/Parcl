(cl:in-package #:parcl)

(defun import (symbols &optional (package *package*))
  (with-client-and-resolved-designators (client
                                         (package package-designator)
                                         (symbols symbol-list-designator))
    (loop for symbol in symbols
          do (parcl.middle:import client package symbol))
    t))
