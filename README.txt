# Mara

Mara is written to do for networked games what lisp does so well: allow writing a bunch of insane code to start out which means you have to write almost no code to do the specific thing you want it to do.

In this case, that means leveraging the MOP to create classes that will automatically update their slots over the network with little to no effort.

While currently completely non-functional, the idea is that code like

(defclass object ()
 ((position :type integer
	    :managed t
	    :serializer :int32))
 (:metaclass mara-class))

Will allow instances of 'object' to be instantiated on one computer and to show up on other clients and then update its 'position' slot automatically in the fashion of modern game networking algorithms.

