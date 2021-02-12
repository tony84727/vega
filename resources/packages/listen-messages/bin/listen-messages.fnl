(local default-websocket "wss://vega.catcatlog.com/api/messages")
(local args [...])
(fn get-websocket-url!
  []
  (let [url (. args 1)]
    (if (~= nil url)
        url
        default-websocket)))
(http.websocketAsync (get-websocket-url!))

(while true
  (match (os.pullEvent)
    ("websocket_success" url websocket) (do (print (.. "connected to " url))
                                     (global ws websocket))
    ("websocket_message" _ message) (print message)
    ("websocket_closed" url) (do
                               (print (.. "websocket closed: " url))
                               (global ws (http.websocketAsync (get-websocket-url!))))))


