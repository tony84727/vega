(local s (peripheral.find "speaker"))

(local notes
       [12 8 3 8 10 15 15 10 12 8 3 8 8])

(fn fami
  []
  (each [_ note (ipairs notes)]
    (s.playNote "flute" 1 note)
    (sleep 0.2)))

(while true
  (match (os.pullEvent)
    "redstone" (fami)))

