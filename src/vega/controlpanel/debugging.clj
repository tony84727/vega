(ns vega.controlpanel.debugging
  (:require [org.httpkit.server :as s]
            [clojure.core.async :as async]
            [ring.util.request :refer [body-string]]))


(defn new-pub [input-ch] (async/pub input-ch (constantly nil)))

(defn handler [pub request]
  (s/with-channel request ch
    (let [sub-ch (async/sub pub nil (async/chan))]
      (s/on-close ch (fn [status] (async/unsub nil sub-ch)))
      (async/go-loop []
        (when-let [msg (async/<! sub-ch)]
          (s/send! ch msg)
          (recur))))))

(defn log-handler [out-ch request] (async/go
                                     (async/>! out-ch (body-string request))) {:status 200 :body "OK"})
