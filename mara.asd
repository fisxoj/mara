;;;; mara.asd

(asdf:defsystem #:mara
  :serial t
  :description "Describe mara here"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LGPLv3"
  :depends-on (#:usocket
               #:userial
	       #:thnappy
	       #:trivial-garbage
	       #:closer-mop)
  :components ((:module src
		:components ((:file "package")
			     (:file "timing")
			     (:module metaclass
			      :components ((:file "db")
					   (:file "class-serializer")
					   (:file "metaclass")
					   ))
			     (:module signaling
			      :components ((:file "opcodes")
					   (:file "message")
					   (:file "sending")
					   (:file "receiving")
					   (:file "client")
					   (:file "server")))
			     (:file "mara")))))

