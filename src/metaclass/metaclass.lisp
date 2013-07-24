(in-package #:mara)

;; Reference material:
;; http://repo.or.cz/w/clsql.git/blob/HEAD:/sql/metaclasses.lisp

#|

The metaclass definitions needed to mark a class as managed by Mara and
to allow the :mara option in slot definitions to mark that slot as network
managed

|#

;; The metaclass itself

(defclass mara-class (standard-class)
  ((managed-slots
    :initform nil
    :accessor managed-slots)
   (serializer-function
    :type function
    :accessor serializer-function)
   (deserializer-function
    :type function
    :accessor deserializer-function))
  (:documentation "Base class that will automatically update slots across the network"))


(defmethod initialize-instance :around ((class mara-class)
					&rest initargs
					&key direct-slots
					&allow-other-keys)
  (let ((managed-slots (loop for slot in direct-slots
			     when (getf slot :managed)
			       collect (getf slot :serializer)
			       and collect (getf slot :name))))

    (setf (managed-slots class) managed-slots)
    (make-serializers class managed-slots)
    #|
    (apply #'call-next-method
	   class
	   :direct-slots (append direct-slots
				 '((:name %id
				    :type integer
				    :writers ((setf object-id))
				    :readers (object-id)
				    :initform (make-id))
				   (:name %dirty
				    :type boolean
				    :writers ((setf dirty))
				    :readers (dirty)
				    :initform nil)))
	   initargs)
    |#
    (call-next-method)))

(defmethod reinitialize-instance :around ((class mara-class)
					  &rest initargs
					  &key direct-slots
					  &allow-other-keys)
  (let ((managed-slots (loop for slot in direct-slots
			     when (getf slot :managed)
			       collect (getf slot :serializer)
			       and collect (getf slot :name))))

    (setf (managed-slots class) managed-slots)
    (make-serializers class managed-slots)
    #|
    (apply #'call-next-method
	   class
	   :direct-slots (append direct-slots
				 '((:name %id
				    :type integer
				    :writers ((setf object-id))
				    :readers (object-id)
				    :initform (make-id))))
	   initargs)
    |#
    (call-next-method)))

;(defmethod initialize-instance :after ((class mara-class)))

;; Allow standard class as a superclass of mara-class so normal class-y things
;; like initializing an instance work

(defmethod closer-mop:validate-superclass ((class mara-class)
					   (superclass standard-class))
  t)

;; Code to read :mara and :serializer

(defclass mara-class-slot-definition-mixin ()
  ((serializer
    :type (or null symbol function)
    :initform nil
    :initarg :serializer
    :documentation "The serializing specifier used by userial.")
   (managed
    :type boolean
    :initform nil
    :reader managed
    :initarg :managed)))

(defclass mara-class-direct-slot-definition (mara-class-slot-definition-mixin
					     closer-mop:standard-direct-slot-definition)
  ())

(defclass mara-class-effective-slot-definition (mara-class-slot-definition-mixin
						closer-mop:standard-effective-slot-definition)
  ())

(defmethod closer-mop:direct-slot-definition-class ((class mara-class)
						    &rest initargs)
  (declare (ignore initargs))
  (find-class 'mara-class-direct-slot-definition))

(defmethod closer-mop:effective-slot-definition-class ((class mara-class)
						       &rest initargs)
  (declare (ignore initargs))
  (find-class 'mara-class-effective-slot-definition))

(defmethod initialize-instance :around ((slot mara-class-direct-slot-definition)
					&rest initargs)
  (let ((managed    (getf initargs :managed))
	(serializer (getf initargs :serializer)))
    (call-next-method)
    (when (and managed (not serializer))
      (error "Asked Mara to manage slot ~A without specifying a serializer"
	     (getf slot :name)))))


(defmethod (setf closer-mop:slot-value-using-class) (new-value
						     (class mara-class)
						     obj
						     (slot mara-class-slot-definition-mixin))
  (format nil "~a ~a" new-value slot)
  (unless (eq (closer-mop:slot-definition-name slot) '%dirty)
    (when (managed slot)
      (setf (dirty obj) t)))
  (call-next-method))

(defclass mara-object ()
  ((%id
    :type integer
    :accessor object-id
    :initform (make-id))
   (%dirty
    :type boolean
    :accessor dirty
    :initform nil))
  (:metaclass mara-class))

(defmacro defmara (name direct-superclasses direct-slots &rest options)
  (let ((superclasses (or direct-superclasses '(mara-object))))
    `(defclass ,name ,superclasses
       ,direct-slots
       ,@options
       (:optimize-slot-access nil)
       (:metaclass mara-class))))
