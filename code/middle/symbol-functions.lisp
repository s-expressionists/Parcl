(cl:in-package #:parcl.middle)

(defmethod keywordp ((client t) (object t))
  (and (parcl.low:symbolp client object)
       ;; TODO: could also compare `package-name' to "KEYWORD"
       (eq (low:symbol-package client object)
           (low:find-package client "KEYWORD"))))
