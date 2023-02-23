(cl:in-package #:parcl)

(defmethod use-packages (client package packages-to-use)
  (let (;; The keys of hash table are symbol names. The value of a key
        ;; is a list with one element for each distinct symbol with the
        ;; key as a name. Each element is alist where the CAR is the
        ;; symbol, and the CDR is a list of packages for which there
        ;; might be a confligt.
        (conflicts (make-hash-table :test #'equal)))
    nil))
