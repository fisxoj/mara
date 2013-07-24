;;;; mara.lisp

(in-package #:mara)

(defun tick ()
  (setf *current-time* (get-internal-real-time))
  (if (server-p)
      (maybe-batch-update)
      (maybe-delta-update))

  (flush-outbox)
  (flush-inbox))
