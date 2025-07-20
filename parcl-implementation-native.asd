(defsystem "parcl-implementation-native"
  :components ((:module     "native"
                :pathname   "code/implementation/native"
                :components ((:file "package"))))
  :in-order-to ((test-op (test-op "parcl-implementation-native/test"))))

(defsystem "parcl-implementation-native/test"
  :depends-on ("fiveam"
               "parcl-implementation-native")
  :components ((:module     "native"
                :pathname   "test/implementation/native"
                :components ((:file "test"))))
  :perform (test-op (operation component)
             (uiop:symbol-call '#:parcl.implementation.native.test '#:run-tests)))
