(ns vega.discord
  (:require [clojure.core.async :as async]
            [discljord.connections :as c]
            [discljord.messaging :as m]))
(def ^:private default-config-path "discord.edn")

(defonce bot (atom nil))
(defonce messaging-ch (atom nil))

(defn load-bot-config!
  []
  (read-string (slurp default-config-path)))

(def get-config!
  (memoize (fn [] (load-bot-config!))))

(defn command-handlers
  [commands messaging-ch]
  (into {} (map (fn [[command message]]
                  [command (fn []
                             (async/go (async/>! messaging-ch message)))])
                commands)))
(defn- parse-command
  [message]
  (second (re-matches #"!(\S+)" message)))

(defn- handle-message-commands
  [handlers event-data]
  (let [{channel-id :channel-id content :content} event-data
        command (parse-command content)
        handler (when command (get handlers command))]
    (when handler
      (handler))))
(defn- create-message-command-handler
  [commands messaging-ch]
  (let [handlers (command-handlers commands messaging-ch)]
    (partial handle-message-commands handlers)))

(defn connect-bot!
  [token commands messaging-ch]
  (let [event-ch (async/chan 100)
        connection-ch (c/connect-bot! token event-ch :intents [:guilds :guild-messages])
        message-ch (m/start-connection! token)
        stop (fn [] (c/disconnect-bot! connection-ch))
        message-handler (create-message-command-handler commands messaging-ch)]
    (async/go
      (try
        (loop []
          (let [[event-type event-data] (async/<! event-ch)]
            (when-not (:bot (:author event-data))
              (when (= :message-create event-type)
                (message-handler event-data)))
            (when-not (= :disconnect event-type)
              (recur))))
        (finally
          (m/stop-connection! message-ch)
          (async/close! event-ch))))
    stop))

(defn start-bot!
  [message-ch]
  (let [token (:token (load-bot-config!))]
    (reset! messaging-ch message-ch)
    (swap! bot (fn [stop] (when stop (stop)) (connect-bot! token (:message-commands (get-config!)) message-ch)))))
