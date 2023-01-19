(local departure-side "top")
(local detector-side "back")
(local assembler-side "right")
(local break-side "left")
(local departure-detector-timeout 4)

(global last-departure false)
(global last-detector false)
(global last-assembler false)
(global timer-id nil)
(global departured false)

(fn get-redstone
  [side]
  (redstone.getInput side))

(fn output-redstone
  [side state]
  (redstone.setOutput side state))

(fn cancel-timer!
  []
  (os.cancelTimer timer-id)
  (global timer-id nil))

(fn reset-timer!
  []
  (if (~= timer-id nil)
      (cancel-timer!))
  (global timer-id (os.startTimer departure-detector-timeout)))

(while true
  (let [(event detail) (os.pullEvent)]
    (if (= event "redstone")
        (do
          (let [input (get-redstone departure-side)]
            (if (and input (~= last-departure input))
                (do
                  (output-redstone assembler-side true)
                  (output-redstone break-side true)
                  (reset-timer!)))
            (global last-departure input))
          (let [input (get-redstone detector-side)]
            (if (and input (~= input last-detector))
                (if departured
                    (do
                      (print "entered")
                      (global departured false)
                      (sleep 0.2)
                      (output-redstone assembler-side false))
                    (reset-timer!)))
            (global last-detector input))))
    (if (and (= event "timer") (= detail timer-id))
        (do
          (cancel-timer!)
          (print "departured")
          (output-redstone break-side false)
          (global departured true)))))
