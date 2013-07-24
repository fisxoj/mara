(in-package #:mara)

(defparameter *state* :server
  "Let's mara know if it's running as a server or client.")

(defparameter +batch-update-interval+ 300
  "Interval in milliseconds after which the server will issue a new update of the universe.")

(defparameter +delta-update-interval+ 20
  "Interval in milliseconds after which delta updates will be sent.")

