(defsystem "parcl-implementation-native"
  :depends-on ("parcl-extrinsic")
  :components ((:module     "native"
                :pathname   "code/implementation/native"
                :components ((:file "package"))))
  :in-order-to ((test-op (test-op "parcl-implementation-native/test"))))

(defsystem "parcl-implementation-native/test"
  :depends-on ("fiveam"

               "parcl-core/test"   ; for `parcl.test::*high-tests*' and
               "parcl-macros/test" ; running macro tests with this backend

               "parcl-implementation-native")
  :components ((:module     "implementation-native"
                :pathname   "test/implementation/native"
                :components ((:file "test"))))
  :perform (test-op (operation component)
             (uiop:symbol-call '#:parcl.implementation.native.test '#:run-tests)))
