(local notes [ 5 5 6 5 8 7 0
             5 5 6 5 9 8 0
             5 5 12 10 8 7 6
             11 0 11 0 10 8 9 8])
(fn tune [t]
  (match t
    5 8
    6 10
    7 12
    8 13
    9 15
    10 17
    11 18
    12 20))

(local s (peripheral.wrap "top"))
(while true
  (match (os.pullEvent)
    ("redstone")
    (for [_ 1 2]
      (each [i n (ipairs notes)]
        (when (= (% i 2) 0)
          (s.playNote "snare" 1 1))
        (when (= (% i 4) 0)
          (s.playNote "basedrum" 2 1))
        (if (> n 0)
            (s.playNote "flute" 3 (tune n))
            (s.playNote "snare" 1 1))
        (sleep 0.2)))))
