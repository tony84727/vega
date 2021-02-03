(local direction-side "bottom")
(local clutch-side "right")
(local detector-side "top")
(local alarm-side "front")
(local sensor-heartbeat-timeout 1.2)
(local rednet-host-interval 4)
(local c-protocol "window-controller")
(local c-host "window-controller")

(global desired-state (not (rs.getInput detector-side)))
(global current-state desired-state)
(global system-ready false)
(global system-not-ready-timer nil)
(global rednet-host-timer (os.startTimer rednet-host-interval))

(fn clutch-output
  [m-system-ready desired-state current-state]
  (and m-system-ready (~= desired-state current-state)))
(fn shaft-output
  [desired-state current-state]
  desired-state)
(fn alarm-output
  [desired-state current-state]
  (~= desired-state current-state))

(each [_ s (ipairs (rs.getSides))]
  (when (= (peripheral.getType s) "modem")
    (rednet.open s)))

(rednet.host c-protocol c-host)

(local chunk-timeout 3)
(fn some-is-negative
  [t]
  (each [_ v (pairs t)]
        (if (< v 0)
            (lua "return true")))
  false)

(fn new-chunk-ready-detector
  [chunks]
  (var chunk-timers {})
  (each [_ c (ipairs chunks)]
    (tset chunk-timers c (os.startTimer chunk-timeout)))
  (fn [...]
    (match ...
      ("rednet_message" distance message protocol)
      (do
        (when (= protocol "chunk-heartbeat")
          (let [origin-timer (. chunk-timers message)]
            (when (>= origin-timer 0)
              (os.cancelTimer origin-timer)))
          (tset chunk-timers message (os.startTimer chunk-timeout))))
      ("timer" timer-id)
      (each [chunk-id chunk-timer (pairs chunk-timers)]
        (when (= chunk-timer timer-id)
          (print (.. "chunk " chunk-id " timed out"))
          (tset chunk-timers chunk-id -1))))
    (not (some-is-negative chunk-timers))))

(global chunk-ready (new-chunk-ready-detector [11 12 15 16 17]))

(while true
  (let [event (table.pack (os.pullEvent))]
    (match (table.unpack event)
      ("rednet_message" distance message protocol)
      (when (= protocol c-protocol)
        (when system-not-ready-timer 
          (os.cancelTimer system-not-ready-timer))
        (global system-not-ready-timer (os.startTimer sensor-heartbeat-timeout))
        (global system-ready true)
        (match message
          "close" (global current-state false)
          "open" (global current-state true)))
      ("timer" timer-id)
      (match timer-id
        system-not-ready-timer (do
                                 (global system-ready false)
                                 (print "system-not-ready:sensor heartbeat timeout"))
        rednet-host-timer (do
                            (rednet.host c-protocol c-host)
                            (global rednet-host-timer (os.startTimer rednet-host-interval)))))
    (global desired-state (not (rs.getInput detector-side)))
    (let [is-chunk-ready (chunk-ready (table.unpack event))]
      (rs.setOutput clutch-side (clutch-output (and system-ready is-chunk-ready) desired-state current-state))
      (rs.setOutput direction-side (shaft-output desired-state current-state))
      (rs.setOutput alarm-side (alarm-output desired-state current-state)))))
