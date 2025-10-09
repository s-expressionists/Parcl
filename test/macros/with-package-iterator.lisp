(cl:in-package #:parcl.test)

(let* ((parcl:*client* (make-instance 'parcl.implementation.native:client))
       (thunk          (make-closure (list (parcl:find-package "CL-USER"))
                                     '(:internal :external :inherited))))
  (let ((cl:*package* (find-package '#:keyword)))
    (loop :for (ok? symbol status package) = (multiple-value-list (funcall thunk))
          :while ok?
          :count 1 :into count
          :do (format *trace-output* "~64S ~32A ~A~%"
                      symbol (package-name package) status)
          :finally (format *trace-output* "~:D symbol~:P~%" count))))

(cl:with-package-iterator (thunk (list (cl:find-package "CL-USER"))
                                 :internal :external :inherited)
  (let ((cl:*package* (cl:find-package '#:keyword)))
    (loop :for (ok? symbol status package) = (multiple-value-list (thunk))
          :while ok?
          :count 1 :into count
          :do (format *trace-output* "~64S ~32A ~A~%"
                      symbol (cl:package-name package) status)
          :finally (format *trace-output* "~:D symbol~:P~%" count))))

#++ (clouseau:inspect (cl:find-package "CL-USER"))


(let ((*client* (make-instance 'parcl.test::mock-client)))
  (let* ((p1 (make-package "P1"))
         (p2 (make-package "P2"))
         (s  (intern "S" p1)))
    (export s p1)
    (use-package p1 p2)
    (with-package-iterator (iterator (list p2) :internal :external :inherited)
      (loop :do (multiple-value-bind (more? symbol status containing-package)
                    (iterator)
                  (if more?
                      (format *trace-output* "~&~A ~A ~A~%" symbol status containing-package)
                      (loop-finish)))))
    (import s p2)
    (export s p2)
    (format *trace-output* "~&----~%")
    (with-package-iterator (iterator (list p2) :internal :external :inherited)
      (loop :do (multiple-value-bind (more? symbol status containing-package)
                    (iterator)
                  (if more?
                      (format *trace-output* "~&~A ~A ~A~%" symbol status containing-package)
                      (loop-finish)))))))

(let* ((p1 (cl:make-package "P1"))
       (p2 (cl:make-package "P2"))
       (s  (cl:intern "S" p1)))
  (cl:export s p1)
  (cl:use-package p1 p2)
  (cl:with-package-iterator (iterator (list p2) :internal :external :inherited)
    (loop :do (multiple-value-bind (more? symbol status containing-package)
                  (iterator)
                (if more?
                    (format *trace-output* "~&~A ~A ~A~%" symbol status containing-package)
                    (loop-finish)))))
  (cl:import s p2)
  (cl:export s p2)
  (format *trace-output* "~&----~%")
  (cl:with-package-iterator (iterator (list p2) :internal :external :inherited)
    (loop :do (multiple-value-bind (more? symbol status containing-package)
                  (iterator)
                (if more?
                    (format *trace-output* "~&~A ~A ~A~%" symbol status containing-package)
                    (loop-finish))))))
