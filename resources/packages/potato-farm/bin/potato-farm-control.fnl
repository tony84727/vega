(rednet.broadcast "controller")
(print "potato farm controller started")

(fn debouncer
  [out]
  (var last nil)
  (fn [input]
    (let [last-p last]
      (set last input)
      (if (or  (= last-p nil) (~= input last-p))
          (out input)))))

(fn handle-redstone-event
  [query-input event on-change]
  )

(fn handle-event
  [event]
  ())
