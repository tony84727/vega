(local default-host "https://vega.catcatlog.com")
(local config-path "/home/.loader/config")

(fn get-host
  []
  (if (fs.exists config-path)
      (let [f (io.open config-path)
            file-size (f:seek "end")]
        (f:seek "set")
        (let [config (f:read file-size)]
          (f:close)
          (. (textutils.unserialize config) "host")))
      default-host))
{"getHost" get-host}
