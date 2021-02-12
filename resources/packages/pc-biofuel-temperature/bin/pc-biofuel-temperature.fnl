(local output-side "top")
(local reconcile-interval 5)
(local component (peripheral.wrap "bottom"))
(rs.setAnalogOutput output-side 15)
(fn blink []
  (rs.setAnalogOutput output-side 13)
  (sleep 0.1)
  (rs.setAnalogOutput output-side 15))

(fn schedule-reconcile! []
  (global reconcile-timer (os.startTimer reconcile-interval)))

(fn reconcile! []
  (let [temp (component.getTemperature)]
    (when (< temp 390) (blink))
    (print (.. "[" (os.clock) "] " "current temperature: " (tostring temp)))))

(schedule-reconcile!)

(while true
  (match (os.pullEvent)
    ("timer" timer-id) (when (= timer-id reconcile-timer)
                         (schedule-reconcile!)
                         (reconcile!))))
