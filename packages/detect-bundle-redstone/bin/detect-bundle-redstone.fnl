(local default-detecting-side "top")
(local args [...])
(fn get-detecting-side []
  (let [side (. args 1)]
    (if side
        side
        default-detecting-side)))
(while true
  (match (os.pullEvent)
    ("redstone") (print (rs.getBundledInput (get-detecting-side)))))
