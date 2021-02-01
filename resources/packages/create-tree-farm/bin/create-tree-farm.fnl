(local cutter-end-side "front")
(local cutter-start-side "right")
(local planter-end-side "left")
(local planter-start-side "back")
(local planter-control "top")
(local cutter-control "bottom")
(local planter-cooldown-time 60)
(local jiggle-interval 0.2)
(local jiggle-cooldown 4)

(global cutter-out true)
(global planter-out true)
(global jiggle-cooldown-timer (os.startTimer jiggle-cooldown))
(global jiggle-timer nil)
(global flip-planter false)
(global planter-cooldown-timer nil)

(while true
  (match (os.pullEvent)
    ("timer" timer-id)
    (match timer-id
      jiggle-cooldown-timer (do
                     (global jiggle-cooldown-timer nil)
                     (global flip-planter true)
                     (global jiggle-timer (os.startTimer jiggle-interval)))
      jiggle-timer (do
                     (global jiggle-timer nil)
                     (global flip-planter false)
                       (global jiggle-cooldown-timer (os.startTimer jiggle-cooldown)))
      planter-cooldown-timer
      (do
        (global planter-cooldown-timer nil)
        (global planter-out true)
        (global jiggle-cooldown-timer (os.startTimer jiggle-cooldown))))
    ("redstone") (do
                   (when (rs.getInput cutter-start-side)
                     (global cutter-out true))
                   (when (rs.getInput cutter-end-side)
                     (global cutter-out false))
                   (when (rs.getInput planter-start-side)
                     (when jiggle-cooldown-timer 
                       (os.cancelTimer jiggle-cooldown-timer))
                     (global jiggle-cooldown-timer nil)
                     (global flip-planter false)
                     (when (not planter-cooldown-timer)
                       (global planter-cooldown-timer (os.startTimer planter-cooldown-time)))
                     (when jiggle-timer
                       (os.cancelTimer jiggle-timer)
                       (global jiggle-timer nil)))
                   (when (rs.getInput planter-end-side)
                     (global planter-out false))))
  (rs.setOutput cutter-control cutter-out)
  (rs.setOutput planter-control (if flip-planter (not planter-out) planter-out)))
