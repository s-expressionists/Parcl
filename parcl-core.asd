;;; This system is not intended to be loaded directly.  The
;;; parcl-core/sentinel system tries to enforce that constraint.
(defsystem "parcl-core"
  :description "Protocols and shared code for package system implementations."
  :license "BSD" ; see LICENSE file
  :author "Robert Strandh"
  :depends-on  ("parcl-core/sentinel"
                "ecclesia"
                "acclimation")
  :components  (;; Code that can be shared between the low and high
                ;; modules as well as different package system
                ;; implementations
                (:module     "common"
                 :pathname   "code"
                 :serial     t
                 :components ((:file "variables")
                              (:file "condition-types")
                              (:file "utilities")
                               ;; Messages
                              (:file "messages-english")))

                (:module     "low"
                 :pathname   "code/low"
                 :depends-on ("common")
                 :serial     t
                 :components ((:file "packages")
                              (:file "accessors")
                              (:file "configuration")
                              (:file "generic-functions")
                              (:file "package-class")
                              (:file "make-package")
                              (:file "find-symbol")
                              (:file "import")
                              (:file "shadowing-import")
                              (:file "use-packages")
                              (:file "unuse-package")
                              (:file "export")
                              (:file "unexport")
                              (:file "unintern")
                              (:file "add-local-nickname")
                              (:file "remove-local-nickname")))

                (:module     "high"
                 :pathname   "code"
                 :depends-on ("common" "low")
                 :serial     t
                 :components ((:file "find-package")
                              (:file "package-name")
                              (:file "package-nicknames")
                              (:file "package-shadowing-symbols")
                              (:file "package-use-list")
                              (:file "package-used-by-list")
                              (:file "intern")
                              (:file "find-symbol")
                              (:file "import")
                              (:file "shadowing-import")
                              (:file "use-package")
                              (:file "unuse-package")
                              (:file "export")
                              (:file "unexport")
                              (:file "shadow")
                              (:file "add-package-local-nickname")
                              (:file "remove-package-local-nickname")
                              (:file "make-package")))))

;;; This system ensures, ideally before any other operations are
;;; attempted, that the PARCL package is already defined when
;;; parcl-core is loaded.  When parcl loaded via either one of the
;;; parcl-intrinsic or parcl-intrinsic system, the PARCL package is
;;; defined before anything else happens and this check succeeds.
(defsystem "parcl-core/sentinel"
  :description "Internal helper system; prevents invalid operations on systems"
  :perform (asdf:prepare-op (operation component)
             (unless (find-package '#:parcl)
               (error "~@<The system ~S must not be loaded directly. Instead, ~
                       either the system ~S or the system ~S has to be ~
                       loaded.~@:>"
                      "parcl-core" "parcl-intrinsic" "parcl-extrinsic"))))
