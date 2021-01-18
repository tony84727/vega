(ns vega.core
  (:gen-class)
  (:require [org.httpkit.server :as s]
            [clojure.core.async :as async]
            [compojure.core :refer :all]
            [compojure.route :as cr]
            [vega.packages :as packages]
            [vega.controlpanel.debugging :as debugging]
            [vega.messages :as messages]
            [ring.util.request :refer [body-string]]))
(defonce server (atom nil))

(defn stop-server []
  (when-not (nil? @server)
    (@server :timeout 100)))

(defn hello [req]
  {:status 200
   :body "Welcome to vega"})
(def debugging-message-ch (async/chan))
(def debugging-pub (debugging/new-pub debugging-message-ch))
(defonce message-ch (atom (async/chan)))
(swap! message-ch (fn [ch] (when ch (async/close! ch)) (async/chan)))

(defroutes all-routes
  (GET "/" [] hello)
  (GET "/packages/*" [] (packages/service "resources/packages/"))
  (GET "/websocket" [] (partial debugging/handler debugging-pub))
  (GET "/api/messages" [] (messages/new-handler @message-ch))
  (POST "/api/push_message" [] (partial messages/post-message-handler @message-ch))
  (POST "/log" [] (partial debugging/log-handler debugging-message-ch))
  (cr/not-found {:status 404 :body "vega can't understand this :<"}))

(defn start-server []
  (reset! server (s/run-server all-routes {:port 8080})))

(defn restart-server []
  (stop-server)
  (start-server))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (start-server)
  (println "vega http server started"))

