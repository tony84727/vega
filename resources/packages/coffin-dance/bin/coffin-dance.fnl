(local notes [7 7 7 7
              5 5 5 5
              8 8 8 8
              9 9 9 9
              6 6 6 6
              6 6 6 6
              6 6 6 6
              5 8 7 4 1 
              1 5 8 7 4
              4 4 8 7 4 1
              1 1 3 2 3 2 3 1
              1 1 3 2 3 2 3 1
              1 5 8 7 4
              4 4 8 7 4 1
              1 3 2 3 2 3 1
              1 3 2 3 2 3
              7 7 7 7
              5 5 5 5
              8 8 8 8
              9 9 9 9
              6 6 6 6
              6 6 6 6
              6 6 6 6
              5 8 7 4 1])

(fn tune
  [n]
  (match n
    1 0
    2 14
    3 15
    5 7
    6 12
    7 3
    8 5
    9 10
    4 2))
(local s (peripheral.find "speaker"))

(each [_ k (ipairs notes)]
  (s.playNote "pling" 1 (tune k))
     (sleep 0.2))
