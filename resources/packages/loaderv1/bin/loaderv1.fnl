(local args [...])
(fn join [sep ...]
  (let [components [...]
        len (length components)]
    (var msg "")
    (each [i c (ipairs components)]
      (set msg (.. msg (if (= i len) c (.. c sep)))))
    msg))
(fn get-url [...]
  (join "/" "https://vega.catcatlog.com"...))
(fn print-help! []
  (print "loaderv1 [add|remove|deps] <package>")
  (print "loaderv1 list"))
(fn get-meta! [pkg]
  (textutils.deserialize (http.get (get-url "package-registry" ))))
(fn add! [pkg]
  ())
(if (< (length args) 1)
    (print-help!)
    (match (. args 1)
      "add" (print "add" (. args 2))
      e (print e))) 
