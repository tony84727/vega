(local url "wss://vega.catcatlog.com/websocket")
(local args [...])
(local id (. args 1))

(if (= nil id)
    (print "usage: turtle-remote <turtle-id>")
    (do
      (http.websocketAsync url)      
      (while true
        (match (os.pullEvent)
          ("websocket_success" _ websocket) (do
                                              (print "connected to Vega")
                                              (global ws websocket))
          ("websocket_closed" _) (do
                                   (print "disconnected, reconnecting...")
                                   (http.websocketAsync url))
          ("char" c) (let [message (match c
                                     "q" (.. "turtle_" id "_up")
                                     "e" (.. "turtle_" id "_down")
                                     "w" (.. "turtle_" id "_forward")
                                     "s" (.. "turtle_" id "_back")
                                     "a" (.. "turtle_" id "_left")
                                     "d" (.. "turtle_" id "_right")
                                     nil)]
                       (when message
                         (ws.send message)
                         (print message))))))
    )
