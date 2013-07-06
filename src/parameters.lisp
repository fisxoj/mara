(in-package #:mara)

(defparameter *state* :server
  "Let's mara know if it's running as a server or client.")

(defparameter +minimum-compression-size+ 2048
  "Size over which mara will automatically compress messages with thnappy.")

(defparameter +batch-update-interval+ 300
  "Interval in milliseconds after which the server will issue a new update of the universe.")


