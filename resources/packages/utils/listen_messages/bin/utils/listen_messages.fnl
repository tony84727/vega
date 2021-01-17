(local default-websocket "wss://vega.catcatlog.com/api/messages")
(global args [...])
(fn get-websocket-url!
  []
  (let [url (. args 1)]
    (if (~= nil url)
        url
        default-websocket)))
(let [url (get-websocket-url!)]
  (print (.. "connecting to " url))
  (let [(ws err) (http.websocket url)]
    (if (~= err nil)
        (print err)
        (while true
          (print (ws.receive))))))


