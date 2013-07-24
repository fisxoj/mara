(in-package #:mara)

(declaim (type integer *current-time*))
(defparameter *current-time* 0)

(defparameter *last-batch-update* 0
  "Time of the last global update of objects")

(defparameter *last-delta-update* 0
  "Time of the last delta update")
