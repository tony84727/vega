(local s (peripheral.find "speaker"))

(fn key-to-note
  [key]
  (match key
    "a" 1
    "s" 3
    "d" 5
    "f" 6
    "g" 8
    "h" 10
    "j" 12
    "q" 13
    "w" 15
    "e" 17
    "r" 18
    "t" 20
    "y" 22
    "u" 24
    "v" 7
))

(while true 
  (match (os.pullEvent)
    ("char" a) (s.playNote "flute" 1 (key-to-note a))
  ))
