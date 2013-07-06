(in-package #:mara)


(userial:make-enum-serializer :update
    (:instantiate
     :update-slot
     :delete))

(defstruct message
  (type :type keyword)
  (timestamp :type (unsigned-byte 32))
  (origin :type usocket:socket))
