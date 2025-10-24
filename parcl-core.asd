;;; This system is not intended to be loaded directly.  The
;;; parcl-core/sentinel system tries to enforce that constraint.
(defsystem "parcl-core"
  :description "Protocols and shared code for package system implementations."
  :license "BSD" ; see LICENSE file
  :author ("Robert Strandh"
           "Jan Moringen")
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
                              (:file "types")
                              (:file "protocol")
                              (:file "package-class")))

                (:module      "middle"
                 :pathname    "code/middle"
                 :depends-on  ("common" "low")
                 :serial      t
                 :components  ((:file "package")
                               (:file "protocol")
                               (:file "utilities")
                               ;; Symbol functions
                               (:file "symbol-functions")
                               ;; Package-package relations
                               (:file "use-packages")
                               (:file "unuse-package")
                               ;; Package-symbol relations
                               (:file "shadowing-symbols")
                               (:file "find-symbol")
                               (:file "intern")
                               (:file "unintern")
                               (:file "import")
                               (:file "shadowing-import")
                               (:file "shadow")
                               (:file "export")
                               (:file "unexport")
                               ;; Environment functions
                               (:file "packages")
                               (:file "find-package-using-package")
                               (:file "make-package")
                               (:file "delete-package")
                               (:file "rename-package")
                               (:file "find-symbols")
                               ;; Extension
                               (:file "local-nicknames")))

                (:module     "high"
                 :pathname   "code"
                 :depends-on ("common" "low" "middle")
                 :serial     t
                 :components ((:file "designator-utilities")
                              ;; Symbol functions
                              (:file "symbol-functions")
                              ;; Package functions
                              (:file "packagep")
                              (:file "package-name")
                              (:file "package-nicknames")
                              (:file "package-use-list")
                              (:file "package-used-by-list")
                              (:file "package-local-nicknames")
                              (:file "package-locally-nicknamed-by-list")
                              (:file "package-shadowing-symbols")
                              (:file "make-package") ; TODO: diagram has this in environment
                              ;; Package-package relation functions
                              (:file "use-package")
                              (:file "unuse-package")
                              (:file "add-package-local-nickname")
                              (:file "remove-package-local-nickname")
                              ;; Package-symbol relation functions
                              (:file "find-symbol")
                              (:file "intern")
                              (:file "import")
                              (:file "shadowing-import")
                              (:file "export")
                              (:file "unexport")
                              (:file "shadow")
                              (:file "unintern")
                              ;; Environment functions
                              (:file "list-all-packages")
                              (:file "find-package")
                              (:file "delete-package")
                              (:file "rename-package")
                              (:file "find-all-symbols"))))
  :in-order-to ((test-op (test-op "parcl-core/test"))))

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

(defsystem "parcl-core/test"
  :depends-on ("alexandria"
               "fiveam"

               "parcl-core")

  :components ((:module     "test"
                :serial     t
                :components ((:file "package")
                             ;; Mock package system
                             (:file "mock-symbol")
                             (:file "mock-package")
                             (:file "mock-client")
                             ;; Utilities
                             (:file "utilities")
                             ;; Tests
                             ;; Package functions
                             (:file "package-local-nicknames")
                             (:file "package-locally-nicknamed-by-list")
                             ;; Package-package relation functions
                             (:file "use-package")
                             (:file "unuse-package")
                             (:file "add-package-local-nickname")
                             (:file "remove-package-local-nickname")
                             ;; Package-symbol relation functions
                             (:file "unintern")
                             (:file "export")
                             (:file "unexport")
                             (:file "import")
                             ;; Environment functions
                             (:file "find-package")
                             (:file "make-package")
                             (:file "delete-package")
                             (:file "rename-package"))))

  :perform     (test-op (operation component)
                 (uiop:symbol-call '#:parcl.test '#:run-tests)))
