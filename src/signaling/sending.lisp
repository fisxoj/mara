(in-package #:mara)

(defparameter *message-outbox* nil)

(defun send-buffer (where buffer)
  ;; Figure out how many destinations to send to
  (let ((destinations (typecase where
			(:client *client-connections*)
			(:server *server-connections*)
			(t where))))
    (dolist (destination destinations)
      (let ((message (make-out-message
		      :seq (incf (connection-seq destination))
		      :ack (connection-last-ack destination)
		      :ack-bitfield (connection-ack-bitfield destination)
		      :destination destination)))
	(package-buffer message buffer)
	(push message *message-outbox*)))))

(defun send (message)
  (push message *message-outbox*))

(defun write-word (int stream)
  "Write a 32 bit integer to a stream (assumes little endianness)"
  (declare (type (unsigned-byte 32) int))
  (write-byte (ldb (byte 8 0) int) stream)
  (write-byte (ldb (byte 8 8) int) stream)
  (write-byte (ldb (byte 8 16) int) stream)
  (write-byte (ldb (byte 8 24) int) stream))

(defun flush-outbox ()
  ;; Empty the list of messages
  (loop
    for message = (pop *message-outbox*)
    while message
    ;; Messages can have multiple destinations (e.g. all the clients)
    do (let* ((destination (out-message-destinations message))
	      (stream (usocket:socket-stream destination)))
	 ;; Write sequence number, acks, and data to the stream,
	 ;; then send it on its way!
	 (write-byte     (message-seq          message) stream)
	 (write-byte     (message-ack          message) stream)
	 (write-byte     (message-ack-bitfield message) stream)
	 (write-word     (message-size         message) stream)
	 (write-sequence (message-content      message) stream)
	 (force-output                             stream)
	 (push message (connection-messages destination)))))
