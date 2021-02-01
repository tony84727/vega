(local id (os.getComputerID))
(each [_ side (ipairs (rs.getSides))]
  (when (= (peripheral.getType side) "modem")
    (rednet.open side)))
(print (.. "broadcasting chunk heartbeat: " id))
(while true
  (rednet.broadcast id "chunk-heatbeat")
  (sleep 2.5))
