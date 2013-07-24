(in-package #:mara)

(userial:make-enum-serializer :opcodes
    (:other
     ;; Misc data for whatever game is using the library
     :welcome
     ;; accepts client to a game/chat room/whatever
     :join
     ;; Request to join a game
     :batch-update
     ;; Server-sent authoritative "Here's everything" message
     :delta-update
     ;; Client note to server for objects it controls
     :chat
     ;; Text messages between players
     :ping
     ;; Used to asses latency
     :pong
     ;; Response to :ping
     ))
