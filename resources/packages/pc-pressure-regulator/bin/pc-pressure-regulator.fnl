(local upper-threshold 4.9)
(local lower-threshold 4.5)
(local reconcile-interval 5)
(local output-side "right")
(local component (peripheral.wrap "back"))
(global current-state false)

(fn schedule-reconcile! []
  (global reconcile-timer (os.startTimer reconcile-interval)))
(schedule-reconcile!)
(fn output [current-state pressure]
  (< pressure (if current-state upper-threshold lower-threshold)))
(fn reconcile! []
  (let [current-pressure (component.getPressure)
        output (output current-state current-pressure)]
    (print (.. "[" (tostring (os.clock)) "] "
               "reconcile, current pressure: " (tostring current-pressure) " compressor: " (if output "on" "off")))
    (rs.setOutput output-side output)
    (global current-state output)))
(while true
  (match (os.pullEvent)
    ("timer" timer-id) (when (= timer-id reconcile-timer)
                         (schedule-reconcile!)
                         (reconcile!))))
