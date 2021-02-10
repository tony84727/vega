(local default-pressure 5.0)
(local reconcile-interval 5)
(local output-side "right")
(local component (peripheral.wrap "back"))

(fn schedule-reconcile! []
  (global reconcile-timer (os.startTimer reconcile-interval)))
(schedule-reconcile!)
(fn reconcile! []
  (rs.setOutput output-side (< (component.getPressure) default-pressure)))
(while true
  (match (os.pullEvent)
    ("timer" timer-id) (when (= timer-id reconcile-timer)
                         (schedule-reconcile!)
                         (reconcile!))))
