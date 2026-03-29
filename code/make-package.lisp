(cl:in-package #:parcl)

(defun make-package (package-name &key nicknames use)
  (with-resolved-designators (client (package-name string-designator)
                                     (nicknames    string-designator-list)
                                     (use          package-designator-list))
    (parcl.middle:make-package client package-name nicknames use)))
