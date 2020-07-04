(ns vega.packages)

(defn package-info
  "serve package info (e.g) md5 hash, last modified. print it out in body beause it's not convenient to read headers from openComputers"
  [id] {:status 200 :body "unimplemented"})

(defn id-handler
  "wrapper for handlers that only want the id of the requesting package"
  [handler]
  (fn [req] (handler (-> req :params :id))))

(defn package-content
  [id]
  {:status 200 :body (slurp (str "lua/packages/" id ".lua"))})

(defn package-repository [root]
  (fn [req] (cond
              (= (-> req :query-string) "md5") (id-handler package-info)
              (constantly true) (id-handler package-content))))
