(local args [...])
(local id (. args 1))
(if (= nil id)
    (print "usage: turtle-remote <turtle-id>")
    (do 
      (while true
        (match (os.pullEvent)
          ("char" c) (let [message (match c
                                     "q" (.. "turtle_" id "_up")
                                     "e" (.. "turtle_" id "_down")
                                     "w" (.. "turtle_" id "_forward")
                                     "s" (.. "turtle_" id "_back")
                                     "a" (.. "turtle_" id "_left")
                                     "d" (.. "turtle_" id "_right")
                                     nil)]
                       (when message
                         (http.post "https://vega.catcatlog.com/api/push_message" message)
                         (print message)))))))
