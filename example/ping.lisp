(defpackage :ping
  (:use :mara :cl))

(ql:quickload '(:lispbuilder-sdl :mara))

(in-package #:ping)

(defclass ball (mara-object)
  ((position :type (simple-array integer (2))
	     :initform (make-array 2 :element-type 'integer
				     :initial-contents '(0 0))
	     :accessor ball-position)
   (color :type sdl:color
	  :initform (sdl:color :r (random 255)
			       :g (random 255)
			       :b (random 255))
	  :accessor ball-color)))

(defun main ()
  (sdl:with-init ()
    (sdl:window 800 600)
    (setf (sdl:frame-rate) 60)
    (sdl:with-events ()
      (:quit-event () t)
      (:idle () 
	     (draw))
      (:key-down-event (:key key)
		       (typecase key
			 (:sdl-key-up (move 1))
			 (:sdl-key-down (move -1)))))))
