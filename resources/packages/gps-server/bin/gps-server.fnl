(local config-path "/etc/gps.conf")
(fn load-config []
  (let [config-file (io.open config-path)
        size (config-file:seek "end")]
    (config-file:seek "set" 0)
    (let [config-str (config-file:read size)
          config (textutils.unserialize config-str)]
      (config-file:close)
      config)
    ))
(each [_ side (ipairs (rs.getSides))]
  (when (= "modem" (peripheral.getType side))
    (let [modem (peripheral.wrap side)]
      (modem.open gps.CHANNEL_GPS))))

(local config (load-config))

(while true
  (match (os.pullEvent)
    ("modem_message" side in-freq reply-freq message distance)
    (when (= message "PING")
      (let [modem (peripheral.wrap side)]
        (modem.transmit reply-freq gps.CHANNEL_GPS config)
        (print "replied GPS ping")))))

