;;;; mara.asd

(asdf:defsystem #:mara
  :serial t
  :description "Describe mara here"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LGPLv3"
  :depends-on (#:usocket
               #:userial
	       #:trivial-garbage
	       #:closer-mop)
  :components ((:file "package")
	       (:module src
		:components ((:module metaclass
			      :components ((:file "metaclass")
					   (:file "class-serializer")
					   (:file "db")))
			     (:module signaling
			      :components ((:file "opcodes")
					   (:file "message")
					   (:file "sending")
					   (:file "receiving")
					   (:file "client")
					   (:file "server"))))
;			(:module timing
;			 :components ((:file "interpolation")))
	       )

               (:file "mara")))

