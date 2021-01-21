(ns vega.discord
  (:require [clojure.core.async :as async]
            [discljord.connections :as c]
            [discljord.messaging :as m]))
(def ^:private default-config-path "discord.edn")

(defn load-bot-config!
  []
  (read-string (slurp default-config-path)))

(defn command-handlers
  [messaging-ch commands]
  (map (fn [[command message]]
         (fn [args]
           (async/go (async/>! messaging-ch message))))
       commands))

(defn- handle-message
  [message-ch event-data]
  (let [{channel-id :channel-id} event-data]
    (m/create-message! message-ch channel-id :content (str event-data))))

(defn connect-bot!
  [token]
  (let [event-ch (async/chan 100)
        connection-ch (c/connect-bot! token event-ch :intents [:guilds :guild-messages])
        message-ch (m/start-connection! token)
        stop (fn [] (c/disconnect-bot! connection-ch))]
    (async/go
      (try
        (loop []
          (let [[event-type event-data] (async/<! event-ch)]
            (when-not (:bot (:author event-data))
              (when (= :message-create event-type)
                (handle-message message-ch event-data)))
            (when-not (= :disconnect event-type)
              (recur))))
        (finally
          (m/stop-connection! message-ch)
          (async/close! event-ch))))
    stop))

(defn start-bot!
  []
  (let [token (:token (load-bot-config!))]
    (connect-bot! token)))
