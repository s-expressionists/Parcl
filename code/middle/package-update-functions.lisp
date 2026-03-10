(cl:in-package #:parcl.middle)

;;;; Utility functions

(defun resolve-symbols (client package-name symbol-names)
  (loop :with package = (parcl::find-undeleted-package-or-error
                         client package-name) ; TODO(jmoringe): error
        :for symbol-name in symbol-names
        :for (symbol status) = (multiple-value-list
                               (find-symbol client package symbol-name))
        :if (not (null status))
          :collect symbol
        :else
          :do (with-simple-restart (continue "Do not ~S the non-existing symbol ~A::~A"
                                             :operation package-name symbol)
                (error "No symbol named ~S in package ~A" symbol-name package)) ; TODO(jmoringe): proper error
        ))

(defun resolve-symbols-in-packages (client package-and-symbols-pairs)
  (loop :for (package-name . symbol-names) :in package-and-symbols-pairs
        :nconc (resolve-symbols client package-name symbol-names)))

;;;; Default methods
;;;
;;; These methods perform the runtime effects of `defpackage';
;;; `ensure-package' is defined as a generic function to allow for
;;; customization and to minimize the code size of the expansion of
;;; `defpackage'.  The performed runtime effects include looking up
;;; referenced packages and symbols, handling package variance and
;;; actually creating or updating the package object.  Variance
;;; handling can include unusing, unexporting, etc. things that were
;;; part of the old definition but are missing from the new definition

(defmethod ensure-package
    ((client t) (name t)
     &rest args
     &key (use                   nil use-supplied-p)
          (shadowing-import-from nil shadowing-import-from-supplied-p)
          (import-from           nil import-from-supplied-p))
  ;; TODO: what if NAME matches a local nickname within the current package?
  (let ((existing-package (find-package-using-package
                           client parcl:*package* name))
        (new-args         (a:remove-from-plist
                           args :use :shadowing-import-from :import-from)))
    ;; Resolve string designators to symbol objects and package
    ;; objects for options that effectively operate on those
    ;; objects.
    (macrolet ((maybe-argument ((variable supplied-p) keyword transformation)
                 `(when ,supplied-p
                    (push (,transformation client ,variable) new-args)
                    (push ,keyword                           new-args))))
      (maybe-argument (use use-supplied-p)
                      :use parcl::package-list<-designator-list)
      (maybe-argument (shadowing-import-from shadowing-import-from-supplied-p)
                      :shadowing-import resolve-symbols-in-packages)
      (maybe-argument (import-from import-from-supplied-p)
                      :import resolve-symbols-in-packages))
    (apply #'ensure-package-using-package client existing-package name
           new-args)))

(defmethod note-variance ((client t) (package t) (aspect t) (event t) (value t))
  (error 'parcl:package-variance-error :package package
                                       :aspect  aspect
                                       :event   event
                                       :value   value))

(defmethod note-variance ((client  t)
                          (package t)
                          (aspect  (eql :use))
                          (event   (eql :remove))
                          (value   t))
  (with-simple-restart (continue "Unuse the package ~S" value)
    (call-next-method)))

(defmethod note-variance ((client  t)
                          (package t)
                          (aspect  (eql :shadow))
                          (event   (eql :remove))
                          (value   t))
  (with-simple-restart (continue "Stop shadowing ~S" value)
    (call-next-method)))

(defmethod note-variance ((client  t)
                          (package t)
                          (aspect  (eql :export))
                          (event   (eql :remove))
                          (value   t))
  (with-simple-restart (continue "Stop exporting the symbol ~S" value)
    (call-next-method)))

(defmethod ensure-package-using-package
    ((client t) (existing-package null) (name t) &rest args &key size)
  (declare (ignore size))
  (let ((new-package (make-package client name '() '()))) ; TODO: pass size
    (apply #'update-package client new-package args)))

(defmethod ensure-package-using-package
    ((client t) (existing-package t) (name t)
     &key (nicknames            '() nicknames-supplied-p)
          (use                  '() use-supplied-p)
          (shadow               '() shadow-supplied-p)
          (shadowing-import     '())
          (import               '())
          (intern               '())
          (export               '() export-supplied-p)
          (documentation        nil documentation-supplied-p)
          ;;
          (update-nicknames     :if-supplied)
          (update-use           :if-supplied)
          (update-shadow        :if-supplied)
          (update-export        :if-supplied)
          (update-documentation :if-supplied))
  ;; Actions that should be performed once all (if any) variance
  ;; issues have been reported and resolved.
  (let ((use-actions              '())
        (unuse-actions            '())
        (shadow-actions           '())
        (shadowing-import-actions '())
        (intern-actions           intern)
        (unintern-actions         '())
        (import-actions           import)
        (export-actions           '())
        (unexport-actions         '()))
    ;; Compare the list of packages specified in the `:use' option to
    ;; the old use-list of EXISTING-PACKAGE, signal variance errors
    ;; for changes and queue the required actions.
    (when (ecase update-use
            ((t)          t)
            (:if-supplied use-supplied-p))
      (let* ((old-use (parcl.low:use-list client existing-package))
             (added   (set-difference use     old-use :test #'eq))
             (removed (set-difference old-use use     :test #'eq)))
        (setf use-actions added)
        (loop :for used-package :in removed
              :do (ecase (note-variance client existing-package :use :remove used-package)
                    (:old) ; keep using
                    (:new (push used-package unuse-actions))))))
    ;; Compare the `:shadow' and `:export' options to the current
    ;; status of each mentioned symbol, signal variance errors for
    ;; changes and queue required, [un]intern, [un]export and shadow
    ;; actions.
    (let ((old-external (make-hash-table :test #'equal))
          (old-shadowed (make-hash-table :test #'equal)))
      ;; Collect old export and shadow status for each symbol in
      ;; EXISTING-PACKAGE.
      (parcl.low:map-symbol-entries
       client
       (lambda (symbol export-status shadow-status)
         (let ((name (parcl.low:symbol-name client symbol))) ; TODO: only when needed?
           (when (eq export-status :external)
             (setf (gethash name old-external) symbol))
           (when shadow-status
             (setf (gethash name old-shadowed) symbol))))
       existing-package)
      ;; Remove the names of symbols that will be shadowing from
      ;; OLD-SHADOWED so that those names will not be reported as
      ;; variance.  Report the remaining symbol names in OLD-SHADOWED
      ;; as variances and possibly queue unintern actions.
      (when (ecase update-shadow
              ((t)          t)
              (:if-supplied shadow-supplied-p))
        (setf shadow-actions shadow)
        (loop :for symbol-name :in shadow
              :do (remhash symbol-name old-shadowed))
        (setf shadowing-import-actions shadowing-import)
        (loop :for symbol      :in shadowing-import
              :for symbol-name =   (parcl.low:symbol-name client symbol)
              :do (remhash symbol-name old-shadowed))
        ;; The remaining entries correspond to removed shadowing
        ;; names.  Report those as variance.
        (a:maphash-values
         (lambda (symbol)
           (ecase (note-variance client existing-package :shadow :remove symbol)
             (:old) ; keep shadowing
             (:new (push symbol unintern-actions))))
         old-shadowed))
      ;; Remove the names of symbols that will external from
      ;; OLD-EXTERNAL so that those names will not be reported as
      ;; variance.  Report the remaining symbol names in OLD-EXTERNAL
      ;; as variable and possibly queue unexport actions.
      (when (ecase update-export
              ((t)          t)
              (:if-supplied export-supplied-p))
        ;; For each entry in `:export', determine the old status of
        ;; the name and the required action.
        (loop :for symbol-name :in export
              :do ;; Remove the SYMBOL-NAME from OLD-EXTERNAL since
                  ;; the remaining contents of OLD-EXTERNAL will be
                  ;; reported as removed exports and thus variance.
                  (remhash symbol-name old-external)
                  (multiple-value-bind (symbol export-status shadow-status)
                      (parcl.low:symbol-entry client symbol-name existing-package)
                    (declare (ignore shadow-status))
                    (case export-status
                      (:external)
                      (:internal
                       (push symbol export-actions))
                      (t
                       (push symbol-name export-actions)))))
        ;; The remaining entries correspond to removed exports.
        ;; Report those as variance.
        (a:maphash-values
         (lambda (symbol)
           (ecase (note-variance client existing-package :export :remove symbol)
             (:old) ; keep exporting
             (:new (push symbol unexport-actions))))
         old-external)))
    ;; Call `update-package' to perform the queued actions.
    (apply #'update-package client existing-package
           :use              use-actions
           :unuse            unuse-actions
           :shadow           shadow-actions
           :shadowing-import shadowing-import-actions
           :import           import-actions
           :intern           intern-actions
           :unintern         unintern-actions
           :export           export-actions
           :unexport         unexport-actions
           (append (when (ecase update-nicknames
                           (t            t)
                           (:if-supplied nicknames-supplied-p))
                     (list :nicknames nicknames))
                   (when (ecase update-documentation
                           (t            t)
                           (:if-supplied documentation-supplied-p))
                     (list :documentation documentation))))))

(defmethod update-package ((client t) (package t)
                           &key (nicknames        nil nicknames-supplied-p)
                                (use              '())
                                (unuse            '())
                                (shadow           '())
                                (shadowing-import '())
                                (import           '())
                                (intern           '())
                                (unintern         '())
                                (export           '())
                                (unexport         '())
                                (documentation    nil documentation-supplied-p))
  ;; Update nicknames but retain the name.  We could probably use more
  ;; fine-grained operators but we go through `rename-package' to not
  ;; skip client customizations via that function.
  (when nicknames-supplied-p
    (let ((name (parcl.low:name client package)))
      (rename-package client package name nicknames)))
  ;; The order of operations is given in the specification entry for
  ;; `defpackage':
  (macrolet ((each (operator list)
               `(loop :for element :in ,list
                      :do (,operator client package element))))
    (each unintern unintern) ; TODO: could cause conflict when done before unuse
    ;; 1. `:shadow' and `:shadowing-import-from'
    (each shadow shadow)
    (each shadowing-import shadowing-import)
    ;; 2. `:use'
    (each unuse-package unuse)
    (use-packages client package use)
    ;; 3. `:import-from' and `:intern'
    (each import import)
    (each intern intern)
    ;; 4. `:export' option.  EXPORT is a list the elements of which
    ;; are either strings or symbol objects.  For string elements,
    ;; intern must be performed prior to export.
    (each unexport unexport)
    (loop :for element :in export
          :for symbol = (typecase element
                          (string (intern client package element))
                          (t      element))
          :do (export client package symbol)))
  ;; Update documentation if supplied.
  (when documentation-supplied-p
    (setf (parcl.low:documentation client package) documentation))
  package)
