(local s (peripheral.find "speaker"))

(fn debouncer [f]
  (var last nil)
  (fn [state]
    (let [prev last]
      (set last state)
      (when (~= prev state)
        (f state)))))

(while true
  (let [play (debouncer (fn [input] (when input (s.playSound "minecolonies:raid.raid_alert_early"))))]
    (match (os.pullEvent)
      ("redstone") (play (rs.getInput "bottom")))))
