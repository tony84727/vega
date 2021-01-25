(while true
  (http.post "https://vega.catcatlog.com/api/push_message" (.. "beacon " (os.getComputerID)))
  (sleep 2))
