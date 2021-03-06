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
  ((id :type integer
       :initform (make-id)
       :accessor object-id)))


(defmethod initialize-instance :after ((object mara-class) &rest intitargs)
  (add-object-to-db object)
;  (transmit)
  )

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
    :reader serializer
    :initarg :serializer
    :documentation "The serializing specifier used by userial.")
   (managed
    :type boolean
    :initform nil
    :initarg :managed
    :reader managed)))

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
    (when (and managed (not serializer))
      (error "Asked Mara to manage slot ~A without specifying a serializer" (closer-mop:slot-definition-name slot))))
  (call-next-method))
