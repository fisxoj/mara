(in-package #:mara)

(defparameter *message-inbox* nil
  "Holds incoming messages until they can be processed.")


;; Source: https://github.com/smanek/ga/blob/master/misc.lisp
;; No license, 7/10/2013
(defun read-word (stream)
  "Read a 32 bit integer from a stream (assumes little endianness"
  (let* ((a (read-byte stream))
	 (b (read-byte stream))
	 (c (read-byte stream))
	 (d (read-byte stream)))
    (declare (type (unsigned-byte 8) a b c d))
    (the (unsigned-byte 32) (dpb a (byte 8 0)
				 (dpb b (byte 8 8)
				      (dpb c (byte 8 16)
					   (dpb d (byte 8 24) 0)))))))

(defun receive-messages ()
  (dolist (connection (if (server-p)
			  *server-connections*
			  *client-connections*))
    (let ((stream (connection-stream connection)))
      (when (listen stream)
	(let ((message
		(make-in-message :origin connection
				 :timestamp (get-internal-real-time))))
	  (setf
	   (message-seq message)          (read-byte stream)
	   (message-ack message)          (read-byte stream)
	   (message-ack-bitfield message) (read-byte stream)
	   (message-size message)         (read-word stream))
	  (read-sequence (message-content message) stream
			 :end (message-size message))

	  (connection-got-message connection message)
	  (push message *message-inbox*)))))) 

(defun flush-inbox ()
  )
