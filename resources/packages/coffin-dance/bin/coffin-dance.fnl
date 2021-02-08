(local notes [7 7 7 7
              5 5 5 5
              8 8 8 8
              9 9 9 9
              6 6 6 6
              6 6 6 6
              6 6 6 6
              5 8 7 4 1
              1 1 5 0 8 0 7 0 4
              4 4 8 7 4 1 0
              1 0 1 3 2 3 2 3 1 0
              1 0 1 3 2 3 2 3 1 0
              1 1 5 0 8 0 7 0 4
              4 4 8 7 4 1 0
              1 1 0 3 2 3 2 3 0 1
              1 1 0 3 2 3 2 3 0 1
              7 7 7 7
              5 5 5 5
              8 8 8 8
              9 9 9 9
              6 6 6 6
              6 6 6 6
              6 6 6 6
              5 8 7 4 1
])

(local default-instrument "harp")
(local args [...])
(fn get-instrument
  []
  (if (. args 1)
      (. args 1)
      default-instrument))

(fn tune
  [n]
  (match n
    1 0
    2 14
    3 15
    4 2
    5 7
    6 12
    7 3
    8 5
    9 10
))
(local s (peripheral.find "speaker"))

(each [_ k (ipairs notes)]
  (if (> k 0)
    (s.playNote (get-instrument) 1 (tune k)))
     (sleep 0.2))
