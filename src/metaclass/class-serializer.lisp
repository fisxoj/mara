(in-package #:mara)

(defun serialize (object buffer)
  (let ((class (class-of object)))
    (funcall (serializer-function class) object buffer)))

(defun deserialize (object buffer)
  (let ((class (class-of object)))
    (funcall (deserializer-function class) object buffer)))

(defun make-serializers (class slots)
  (setf (serializer-function class)
	(compile nil 
		 `(lambda (object buffer)
		    (declare (optimize speed (debug 0) (compilation-speed 0)))
		    (userial:with-buffer buffer
		      (userial:serialize-slots* object
						,@slots))))
	(deserializer-function class)
	(compile nil
		 `(lambda (object buffer)
		    (declare (optimize speed (debug 0) (compilation-speed 0)))
		    (userial:with-buffer buffer
		      (userial:unserialize-slots* object
						  ,@slots))))))
