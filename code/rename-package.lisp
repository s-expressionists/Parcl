(cl:in-package #:parcl)

(defun rename-package (package new-name &optional new-nicknames)
  (with-client-and-resolved-designators (client
                                         (package       package-designator)
                                         (new-name      string-designator)
                                         (new-nicknames string-designator-list))
    (if (not (null package))
        (parcl-low:rename-package client package new-name new-nicknames)
        nil)))

(setf (documentation 'rename-package 'function)
      (format nil
              "Syntax: rename-package TODO~@
               ~@
               TODO"))
