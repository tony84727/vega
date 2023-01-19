(local default-websocket "wss://vega.catcatlog.com/api/messages")
(local args [...])
(fn get-websocket-url!
  []
  (let [url (. args 1)]
    (if (~= nil url)
        url
        default-websocket)))
(http.websocketAsync (get-websocket-url!))

(local id (os.getComputerID))
(fn handle-message! [message]
  (let [header (.. "turtle_" id "_")
        up (.. header "up") 
        down (.. header "down")
        right (.. header "right")
        left (.. header "left")
        back (.. header "back")
        forward (.. header "forward")]
    (match message
      up (turtle.up)
      down (turtle.down)
      right (turtle.turnRight)
      left (turtle.turnLeft)
      forward (turtle.forward)
      back (turtle.back))))

(while true
  (match (os.pullEvent)
    ("websocket_success" url websocket) (do (print (.. "connected to " url))
                                     (global ws websocket))
    ("websocket_message" _ message) (handle-message! message)
    ("websocket_closed" url) (do
                               (print (.. "websocket closed: " url))
                               (global ws (http.websocketAsync (get-websocket-url!))))))
