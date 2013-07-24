(in-package #:mara)

(defparameter *message-seq* 0
  "Number of messages sent in sequence")

(userial:make-enum-serializer :update
    (:instantiate
     :update-slot
     :delete))

(defstruct message
  (timestamp    0   :type integer)
  (seq          0   :type (unsigned-byte 32))
  (ack          0   :type integer)
  (ack-bitfield 0   :type (unsigned-byte 32))
  (size         0   :type integer)
  (content      nil))

#|
(userial:define-serializer (:message message)
  (userial:serialize-slots* message
			    :int8  seq
			    :int32 ack
			    :int32 ack-bitfield
			    :bytes content))

(userial:define-unserializer (:message)
  (userial:unserialize-slots* (make-in-message)
			      :int8  seq
			      :int32 ack
			      :int32 ack-bitfield
			      :bytes content))
|#

(defstruct (in-message (:include message))
  (origin  nil :type connection))

(defstruct (out-message (:include message))
  (destination nil :type connection))
