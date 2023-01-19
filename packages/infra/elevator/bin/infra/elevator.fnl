(local vega "wss://vega.catcatlog.com/api/messages")
(local output-side "top")
(http.websocketAsync vega)

(while true
  (match (os.pullEvent)
    ("websocket_success" url websocket) (do (print "connected to vega")
                                            (global ws websocket))
    ("websocket_message" _ message) (match message
                                      "elevator-0-down" (redstone.setOutput output-side true)
                                      "elevator-0-up" (redstone.setOutput output-side false))
    ("websocket_closed") (do
                           (print "disconnected. reconnecting....")
                           (http.websocketAsync vega))))
