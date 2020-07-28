(ns vega.discord
  (:require [clj-yaml.core :as yaml]
            [clojure.core.async :as a]
            [discljord.connections :as c]
            [discljord.messaging :as m]))

(defn get-token []
  (-> (yaml/parse-string (slurp "config.yml"))
      (:discord)
      (:token)))

(defn spawn-bot
  "spawn and start a bot and return a stop channel"
  [token]
  (let [shutdown-ch (a/chan)
        event-ch (a/chan)
        connection-ch (c/connect-bot! token event-ch)
        message-ch (m/start-connection! token)]
    (try (a/go-loop []
           (a/alt! 
             [event-ch] ([[event-type event-data]]
                 (when (= :channel-pins-update event-type)
                   (c/disconnect-bot! connection-ch))
                 (when-not (= :disconnect event-type)
                   (recur)))
             [shutdown-ch] ([] (c/disconnect-bot! connection-ch))))
         (finally
           (m/stop-connection! message-ch)
           (a/close! event-ch)))
    shutdown-ch))

(defonce bot (atom nil))
(defn start [token]
  (swap! bot (fn [previous]
                        (when-not (nil? previous) (a/close! previous))
               (spawn-bot token))))

(defn stop []
  (swap! bot
         (fn [previous ]
           (when-not (nil? previous) (a/close! previous))
           nil)))
