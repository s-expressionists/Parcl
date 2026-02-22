(cl:in-package #:parcl.middle)

(defmethod unintern ((client t) (package t) (symbol t))
  (let ((name (low:symbol-name client symbol)))
    ;; TODO: use (map-accessible-entries-with-name)
    (multiple-value-bind (present-symbol export-status shadow-status)
        (low:symbol-entry client name package)
      (flet ((remove-symbol ()
               (setf (low:symbol-entry client name package) nil)
               ;; If PACKAGE is the home package of SYMBOL, reset the
               ;; home package to `nil'.
               (when (eq (low:symbol-package client symbol) package)
                 (setf (low:symbol-package client symbol) nil))))
        (cond ((or (null export-status) (not (eq present-symbol symbol)))
               ;; not present or a different symbol altogether
               nil)
              (shadow-status ; present and shadowing
               (let ((unique    '())
                     (conflicts '()))
                 ;; TODO: use status argument
                 (map-inheritable-entries-with-name
                  client
                  (lambda (conflict-package conflict-symbol export-status shadow-status)
                    (declare (ignore export-status shadow-status))
                    (pushnew conflict-symbol unique :test #'eq)
                    (push (cons conflict-symbol conflict-package) conflicts))
                  name package)
                 (cond ((null (cdr unique))
                        ;; no conflict between multiple inherited symbols
                        (remove-symbol)
                        t)
                       (t ; conflict between multiple inherited symbols
                        (restart-case
                            (error 'parcl:symbol-conflicts-error
                                   :package        package
                                   :conflicts      `((,name . ((,symbol . ,package)
                                                               ,@conflicts)))
                                   :package-labels `((,package . "using package")
                                                     ,@(loop :for (nil . package) :in conflicts
                                                             :collect `(,package . "exporting package"))))
                          (#1=parcl::abort-operation ()
                            :report (lambda (stream)
                                      (parcl::report-restart '#1# stream 'unintern))
                            nil)
                          #+TODO-choose-which-symbol-to-inherit
                          (parcl:
                              (remove-symbol)
                            shadowing-import the chosen one
                            t))))))
              (t ; present and not shadowing
               (remove-symbol)
               t))))))
