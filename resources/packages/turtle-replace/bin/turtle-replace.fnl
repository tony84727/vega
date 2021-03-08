(local input-side "top")

(fn replace! []
  (turtle.select 1)
  (turtle.dig)
  (turtle.place 1))

(while true
  (match (os.pullEvent)
    ("redstone") (when (redstone.getInput input-side) (replace!))))
