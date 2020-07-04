(ns vega.core
  (:gen-class)
  (:require [org.httpkit.server :as s]
            [compojure.core :refer :all]
            [compojure.route :as cr]
            [vega.packages :as packages]))
(defonce server (atom nil))

(defn stop-server []
  (when-not (nil? @server)
    (@server :timeout 100)))

(defn hello [req]
  {:status 200
   :body "Welcome to vega"})


(defroutes all-routes
  (GET "/" [] hello)
  (GET "/packages/:id" [] (packages/package-repository "lua/packages"))
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
