(fn run-term [target f]
  (let [origin (term.current)]
    (term.redirect target)
    (f)
    (term.redirect origin)))

(fn ostime-to-seconds [time]
  (* time 3600))

(fn format-seconds [seconds]
  (let [minutes (math.floor (/ seconds 60))
        seconds (math.floor (% seconds 60))]
    (string.format "%02dm%02ds" minutes seconds)))

(fn seconds-to-sunset [seconds-of-day]
  (- (* 18 60 60) seconds-of-day))

(fn mc-seconds-irl [seconds]
  (/ seconds 72))

(fn sunset-notification [time]
  (if (>= time 18)
      "NIGHT!"
      (.. "ETA: "
          (format-seconds
           (mc-seconds-irl (seconds-to-sunset (ostime-to-seconds time))))
          " sunset")))

(fn update-screen! [target]
  (run-term target
            (fn []
              (let [time (os.time)]
                (term.clear)
                (term.setCursorPos 1 1)
                (print (textutils.formatTime time))
                (term.setCursorPos 1 2)
                (print (sunset-notification time))))))

(local monitor (peripheral.find "monitor"))
(monitor.setTextScale 2)
(global update-timer (os.startTimer (/ 60 72)))

(while true
  (match (os.pullEvent)
    ("timer" timer-id) (when (= timer-id update-timer)
                         (update-screen! monitor)
                         (global update-timer (os.startTimer (/ 60 72))))))
