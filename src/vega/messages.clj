(ns vega.messages
  (:require [org.httpkit.server :refer [as-channel send!]]
            [ring.util.request :refer [body-string]]
            [clojure.core.async :as async]
            [qbits.alia :as alia]
            [vega.database :as db]))

(defn new-pub
  [input-ch]
  (async/pub input-ch (constantly nil) (constantly (async/sliding-buffer 10))))

(defn websocket-handler
  [pub req]
  (let [sub (atom nil)]
    (as-channel req
                {:on-open (fn [ch] (let [sub-ch (async/chan)]
                                     (async/sub pub nil sub-ch)
                                     (async/go-loop []
                                       (when-let [message (async/<! sub-ch)]
                                         (send! ch message)
                                         (recur)))
                                     (reset! sub sub-ch)))
                 :on-close (fn [ch status] (async/unsub pub nil @sub) (async/close! @sub))})))

(defn post-message-handler
  [output-ch request]
  (let [message (body-string request)]
    (async/>!! output-ch
               message)
    {:status 200 :body "OK"}))

(defn resolve-command-message
  [message-ch command]
  (let [messages (alia/execute (db/get-session!) "SELECT messages FROM command_messages WHERE command = ?" {:values [command]})]
    (fn []
      (println messages))))
