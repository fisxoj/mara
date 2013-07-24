(defpackage :ping
  (:use :mara :cl))

(ql:quickload '(:lispbuilder-sdl :mara))

(in-package #:ping)

(mara::defmara ball ()
  ((position :type (simple-array integer (2))
	     :initform (make-array 2 :element-type 'integer
				     :initial-contents '(0 0))
	     :accessor ball-position
	     :serializer :vec2
	     :managed t)
   (color :initform #(1 1 0)
	  :accessor ball-color)))

(defun main (&optional (server t))
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
