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

(defmacro serializer (class-name slots)
  (list 'progn
	`(defmethod serialize ((object ,class-name)
			       buffer)
	   (userial:with-buffer buffer
	     (userial:serialize-slots* object
				       . ,slots))))))

(defmacro make-serializer-methods-for-class (class managed-slots)
  (let ((slots (gensym "SLOTS"))
	(class-name  (gensym "NAME")))
    `(let ((,slots ,managed-slots)
	   (,class-name  ,(class-name class)))
       #|
       (progn
	 (defmethod serialize ((object ,class-name)
			       buffer)
	   (userial:with-buffer buffer
	     `(userial:serialize-slots* object
					,@slots)))
	 (defmethod deserialize ((object `,name)
				 buffer)
	   (userial:with-buffer buffer
	     (userial:unserialize-slots* object
					 ,@slots))))
       |#
       ,(msmfc class-name managed-slots))))

(defun msmfc (class-name managed-slots)
  `(progn
     (defmethod serialize ((object ,class-name) buffer)
       (userial:with-buffer buffer
	 (userial:serialize-slots* object
				   ,@managed-slots)))

    (defmethod deserialize ((object ,class-name) buffer)
       (userial:with-buffer buffer
	 (userial:unserialize-slots* object
				     ,@managed-slots)))))
