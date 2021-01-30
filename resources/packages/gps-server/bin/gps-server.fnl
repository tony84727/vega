(local config "/etc/gps.conf")
(fn load-config []
  (let [config-file (io.open config)
        size (config-file:seek "end")]
    (config-file:seek "set" 0)
    (let [config-str (config-file:read size)
          config (textutils.unserialize config-str)]
      (config-file:close)
      config)
    ))
(each [_ side (ipairs (rs.getSides))]
  (when (peripheral.getType side)
    (rednet.open side)))

(while true
  (print (rednet.receive)))
