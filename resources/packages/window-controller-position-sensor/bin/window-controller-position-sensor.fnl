(local open-side "bottom")
(local close-side "right")
(local protocol "window-controller")

(each [_ s (ipairs (rs.getSides))]
  (when (= (peripheral.getType s) "modem")
      (rednet.open s)))

(global controller-host (rednet.lookup "window-controller" "window-controller"))
(fn log [message]
  (.. "[" (os.clock) "] " message))
(while (= nil controller-host)
  (log "unable to loolup the window controller, will retry after 5 seconds")
  (sleep 5)
  (global controller-host (rednet.lookup "window-controller" "window-controller")))

(global heartbeat-timer (os.startTimer 1))

(fn report []
  (when (rs.getInput open-side)
    (rednet.send controller-host "open" protocol))
  (when (rs.getInput close-side)
    (rednet.send controller-host "close" protocol)))

(fn heartbeat []
  (rednet.send controller-host "heartbeat" protocol))

(if controller-host 
    (while true
      (match (os.pullEvent)
        ("timer" timer-id)
        (when (= timer-id heartbeat-timer)
          (heartbeat)
          (global heartbeat-timer (os.startTimer 1)))
        ("redstone") (report)))
    (log "cannot find the controller"))
