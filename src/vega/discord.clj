(ns vega.discord
  (:require [clojure.core.async :as async]
            [discljord.connections :as c]
            [discljord.messaging :as m]))
(def ^:private default-config-path "discord.edn")

(defn load-bot-config!
  []
  (read-string (slurp default-config-path)))


(comment (let [event-ch (async/chan 100)
               connection-ch (c/connect-bot! token event-ch)
               message-ch (m/start-connection! token)]
           (try
             (loop []
               (let [[event-type event-data] (async/<)])))))
