(ns vega.messages
  (:require [org.httpkit.server :refer [as-channel send!]]
            [ring.util.request :refer [body-string]]
            [clojure.core.async :as async]))

(defn new-handler
  [message-ch]
  (let [pub (async/pub message-ch (constantly nil))]
    (fn [req]
      (let [sub (atom nil)]
        (as-channel req
                    {:on-open (fn [ch] (let [sub-ch (async/chan)]
                                         (async/sub pub nil sub-ch)
                                         (async/go-loop []
                                           (when-let [message (async/<! sub-ch)]
                                             (send! ch message)
                                             (recur)))
                                         (reset! sub sub-ch)))
                     :on-close (fn [ch status] (async/unsub pub nil @sub))})))))

(defn post-message-handler
  [output-ch request]
  (let [message (body-string request)]
    (async/go
      (async/>! output-ch
                message))
    {:status 200 :body "OK"}))
