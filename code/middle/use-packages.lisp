(cl:in-package #:parcl.middle)

;;; Currently, we do not offer any restarts.  The dictionary entry on
;;; USE-PACKAGE does not say that a correctable error has to be
;;; signaled, but in section 11.1.1.2.5, it is said that any time a
;;; name conflict is about to occur, a correctable error is signaled.
;;; So at some point, we must define restarts.  The problem is to
;;; define exactly what restarts are useful, in particular so that
;;; they can be used programmatically.

;;; TODO: why does this low-level operator accept multiple packages at once? i guess it is more efficient this way
(defmethod use-packages ((client t) (package t) (packages-to-use t))
  ;; The specification states that neither PACKAGE nor any element of
  ;; PACKAGES-TO-USE can be the KEYWORD package.
  (let ((keyword-package (low:find-package client "KEYWORD")))
    (when (eq package keyword-package)
      (error 'parcl:used-by-keyword-package-forbidden-error
             :package keyword-package))
    (when (find keyword-package packages-to-use :test #'eq)
      (error 'parcl:using-keyword-package-forbidden-error :package package)))
  ;; With the KEYWORD package out of the picture, compute the changed
  ;; use-list, check for conflicts and commit the changes.
  (let* ((old-uses           (low:use-list client package))
         (added-uses         (set-difference packages-to-use old-uses
                                             :test #'eq))
         (new-uses           (append added-uses old-uses))
         (accessible-symbols '())
         (conflicts          '()))
    (unless (null added-uses)
      ;; Look for conflicts among the present symbols of PACKAGE and
      ;; the symbols PACKAGE would inherit from all packages in
      ;; NEW-USES.
      (map-accessible-entries
       client
       (lambda (other-package symbol export-status shadow-status)
         (declare (ignore export-status shadow-status))
         (let* ((name      (low:symbol-name client symbol))
                (info      (cons symbol other-package))
                (collision (find name accessible-symbols
                                 :key #'car :test #'string=)))
           (cond ((null collision)
                  (push (cons name (list info)) accessible-symbols))
                 (t
                  (unless (find symbol (cdr collision) :key #'car :test #'eq)
                    (push info (cdr collision))
                    (pushnew collision conflicts :test #'eq))))))
       package new-uses)
      ;; Signal conflicts.
      (unless (null conflicts)
        (error 'parcl:symbol-conflicts-error
               :package        package
               :conflicts      conflicts
               :package-labels (nconc
                                (list (cons package "using"))
                                (loop :for package :in old-uses
                                      :collect (cons package "old used"))
                                (loop :for package :in added-uses
                                      :collect (cons package "new used")))))
      ;; Update use and used-by relations.
      (setf (low:use-list client package) new-uses)
      (loop :for used-package :in added-uses
            :do (push package (low:used-by-list client used-package)))))
  t)
