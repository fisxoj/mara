(in-package #:mara)

(defparameter +minimum-compression-size+ 2048
  "Size over which mara will automatically compress messages with thnappy.")

(defun package-buffer (message buffer)
  "Fills a message struct with data for sending, optionally compressing it."
  (userial:with-buffer buffer
    (let ((size (userial:buffer-length)))
      (userial:buffer-rewind)
      (if (> size +minimun-compression-size+)
	  (setf
	   (message-content message) (thnappy:compress-byte-vector (subseq buffer 0 size))
	   (message-size    message) (length (message-content message)))
	  (setf
	   (message-content message) (sunseq buffer 0 size)
	   (message-size    message) size)))))

(defun unpackage-buffer (message buffer)
  "Fills message struct with data from buffer, possibly decompressing it."
  (userial:with-buffer buffer
    (let ((size (userial:buffer-length)))
      (userial:buffer-rewind)
      ;; Check if buffer is compressed (check for snappy signature)
      (if (and (= (userial:buffer-get-byte) 4)
	       (= (userial:buffer-get-byte) 12))
	  ;; Compressed
	  (progn
	    (userial:buffer-rewind)
	    (setf
	     (message-content message) (thnappy:compress-byte-vector buffer)
	     (message-size    message) (length (message-content message))))


	  (setf
	   (message-content message) (sunseq buffer 0 size)
	   (message-size    message) size)))))
