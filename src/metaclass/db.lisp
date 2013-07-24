(in-package #:mara)

(defparameter *last-id* 0)

(defparameter *freed-ids* nil)

(defparameter +default-db-size+ 1000)

(defun make-db (&optional (initial-size +default-db-size+))
  (make-array initial-size
;	      :element-type 'weak-pointer
	      :adjustable t
	      :fill-pointer 0))

(defparameter *db* (make-db))

(defun make-id ()
  "Retrieve the last freed id # from *last-id* or assign the next db number
based on the fill pointer of the db."
  (or (pop *freed-ids*)
      (incf *last-id*)))

(defun add-object-to-db (object)
  (setf (object-id object) (make-id))
  (vector-push-extend (trivial-garbage:make-weak-pointer object) *db*))

(defun lookup-object-by-id (id)
  (find id *db* :key #'object-id :test #'=))

(defun remove-object-from-db (object)
  (setf *db* (remove (object-id object)
		     *db*
		     :key #'object-id
		     :test #'=))
  (push (object-id object) *freed-ids*))
