(in-package #:mara)


(userial:make-enum-serializer :update
    (:instantiate
     :update-slot
     :delete))

(defstruct message
  (type nil :type (or null keyword))
  (timestamp 0 :type (unsigned-byte 32))
  (origin  nil :type usocket:datagram-usocket))
