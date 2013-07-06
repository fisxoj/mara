(in-package #:mara)

(defparameter *last-id* nil)

(defparameter +default-db-size+ 1000)

(defun make-db (&optional (initial-size +default-db-size+))
  (make-array initial-size
	      :element-type 'weak-pointer
	      :adjustable t
	      :fill-pointer 0))

(defparameter *db* (make-db))

(defun make-id ()
  "Retrieve the last freed id # from *last-id* or assign the next db number
based on the fill pointer of the db."
  (or (pop *last-id*)
      (fill-pointer *db*)))

(defun add-object-to-db (object)
  (setf (object-id object) (make-id))
  (setf (aref *db* (object-id object)) (trivial-garbage:make-weak-pointer object)))

(defun lookup-object-by-id (id)
  (aref *db* id))
