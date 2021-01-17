(local args [...])
(local message (. args 1))
(if message
    (http.post "https://vega.catcatlog.com/api/push_message" message)
    (= message nil)
    (print "Usage: send_message <message>"))
