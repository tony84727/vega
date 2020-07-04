(ns vega.core
  (:gen-class)
  (:require [org.httpkit.server :as s]
            [compojure.core :refer :all]
            [compojure.route :as cr]))
(defonce server (atom nil))

(defn stop-server []
  (when-not (nil? @server)
    (@server :timeout 100)))

(defn hello [req]
  {:status 200
   :body "Welcome to vega"})

(defn serve-package-content
  [id]
  {:status 200 :body (slurp (str "lua/packages/" id ".lua"))})

(defn package-info
  "serve package info (e.g) md5 hash, last modified. print it out in body beause it's not convenient to read headers from openComputers"
  [req] {:status 200 :body "unimplemented"})

(defn package-repository
  "host packages repositories"
  [packages_root]
  (fn [req] (cond
              (= (-> req :query-string) "md5") package-info
              (constantly true) (fn [req] (serve-package-content (-> req :params :id))))))
(defroutes all-routes
  (GET "/" [] hello)
  (GET "/packages/:id" [] package-repository)
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
