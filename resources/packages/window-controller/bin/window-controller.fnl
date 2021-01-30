(local direction-side "bottom")
(local clutch-side "right")
(local detector-side "top")
(local alarm-side "front")
(local sensor-heartbeat-timeout 1.2)

(global desired-state (rs.getInput detector-side))
(global current-state desired-state)
(global system-ready false)
(global system-not-ready-timer nil)

(fn clutch-output
  [system-ready desired-state current-state]
  (and system-ready (~= desired-state current-state)))
(fn shaft-output
  [desired-state current-state]
  (not desired-state))
(fn alarm-output
  [desired-state current-state]
  (~= desired-state current-state))

(each [_ s (ipairs (rs.getSides))]
  (when (= (peripheral.getType s) "modem")
    (rednet.open s)))
(rednet.host "window-controller" "window-controller")

(while true
  (match (os.pullEvent)
    ("rednet_message" distance message protocol)
    (when (= protocol "window-controller")
      (when system-not-ready-timer 
        (os.cancelTimer system-not-ready-timer))
      (global system-not-ready-timer (os.startTimer sensor-heartbeat-timeout))
      (global system-ready true)
      (match message
        "close" (global current-state false)
        "open" (global current-state true)))
    ("timer" timer-id)
    (when (= timer-id system-not-ready-timer)
      (global system-ready false)
      (print "system-not-ready:sensor heartbeat timeout")))
  (global desired-state (not (rs.getInput detector-side)))
  (rs.setOutput clutch-side (clutch-output system-ready desired-state current-state))
  (rs.setOutput direction-side (shaft-output desired-state current-state))
  (rs.setOutput alarm-side (alarm-output desired-state current-state))
)
