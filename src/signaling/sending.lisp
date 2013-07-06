(in-package #:mara)

(defparameter *message-outbox* nil)

(defun send-now (where message)
  ;; Figure out how many destinations to send to
  (let ((connections (typecase where
		       (:all *client-connections*)
		       (:server (list *server-connection*))
		       (t where))))
    (userial:with-buffer (userial:make-buffer)
      (userial:serialize :opcode :compressed)

      (dolist (connection connections)
	(write-sequence (thnappy:compress-byte-vector message)
			(usocket:socket-stream connection))))))

(defun send (where message)
  (push (list where message) *message-outbox*))

(defun receive ()
  (if (eq *state* :server)
      ;; Receive from all clients
      
      ))
