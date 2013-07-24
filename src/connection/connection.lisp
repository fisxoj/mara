(in-package #:mara)

(declaim (type integer
	       +lower-rate-latency+
	       +increase-rate-latency+
	       +rate-change-limit+))

(defparameter +lower-rate-latency+ 300
  "Max latency (ms) before lowering the rate of messages to a connection.")

(defparameter +increase-rate-latency+ 20
  "Minimum latency value (ms) before increasing message rate to a connection.")

(defparameter +rate-change-limit+ 1000
  "Minimum wait time before reassesing the rate for a connection.")

(defparameter +latency-calculation-function+
  (compile nil (lambda (old new)
		 (declare (type integer old new))
		 ;; Geometric mean is more interesting!
		 (/ (+ (/ 1 old) (/ 1 new))))))

(defstruct connection
  "Represents a connection to another client or server. Keeps track of the last message in received from that connection and the round trip time (latency) of the connection.  Also stores rate, which determines how many of all generated messages to send."
  (socket nil)
  ;; messages stores messages until they've been ack'ed for re-sending?
  (messages nil :type list)
  ;; stores calculated latency
  (latency 0 :type integer)
  (rate 0 :type integer)
  (last-adjustment 0 :type integer)
  (seq 0 :type integer)
  (last-ack 0 :type integer)
  (ack-bitfield 0 :type (unsigned-byte 32)))

(defun check-latency (connection)
  (when (> (- *current-time* (connection-last-adjustment connection))
	   +rate-change-limit+)
    (cond
      ((> (connection-latency connection) +lower-rate-latency+)
       (incf (connection-rate connection)))
      ((< (connection-latency connection))
       (decf (connection-rate connection))))))

(defun connection-stream (connection)
  "Returns the stream associated with a connection"
  (usocket:socket-stream (connection-socket connection)))

(defun latest-ack-p (connection seq)
  (> seq (connection-last-ack connection)))

(defun got-message-p (connection seq)
  "Checks if seq is recorded as received."
  (cond
    ((> seq (connection-last-ack connection))
      nil)
      ;; 
    ((or (= seq (connection-last-ack connection))
	 (< seq (- (connection-last-ack connection) 512)))
     t)
    (t (logbitp (- (connection-last-ack connection) seq 1)
		(connection-ack-bitfield connection)))))

(defun connection-got-message (connection message)
  "Adjusts the fields in the connection that track what messages have been acknowledged as received, then removes messages from the waiting queue"
  (let ((seq (message-seq message)))
    (unless (got-message-p connection seq)
      (when (latest-ack-p connection seq)
	(setf (connection-last-ack connection)
	      seq
	      (connection-ack-bitfield connection)
	      (ash (connection-ack-bitfield connection) 1)))
      ;; Clear the message and calculate latency
      (let* ((pos (position-if (lambda (message)
				 (= (message-seq message) seq))
			       (connection-messages connection)))
	     (message (nth pos (connection-messages connection)))
	     (latency (- (get-internal-real-time) (message-timestamp message))))
	(remove message (connection-messages connection)
		:test (lambda (message1 message2)
			(= (message-seq message1) (message-seq message2))))
	(setf (connection-latency connection)
	      (funcall +latency-calculation-function+
		       (connection-latency connection)
		       latency))))))

(defun flush-connection-message-store (connection)
  "Cleans out the stored messages that have been ack'ed by the other end"
  (setf (connection-messages connection)
	(remove-if (lambda (message)
		     (got-message-p connection (message-seq message)))
		   (connection-messages connection))))
