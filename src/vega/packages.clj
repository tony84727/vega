(ns vega.packages
  (:require [taoensso.timbre :as l])
  (:import [java.security MessageDigest]))

(defn md5 [^String s]
  (let [algorithm (MessageDigest/getInstance "MD5")
        raw       (.digest algorithm (.getBytes s))]
        (format "%032x" (BigInteger. 1 raw))))

(defn id-handler
  "wrapper for handlers that only want the id of the requesting package"
  [handler]
  (fn [req] (handler (-> req :params :id))))

(defn package-file [root id] (slurp (str root id ".lua")))

(defn package-info
  "serve package info (e.g) md5 hash, last modified. print it out in body beause it's not convenient to read headers from openComputers"
  [root id] {:status 200 :body (md5 (package-file root id))})

(defn package-header [content] (str "--[[" (md5 content) "]]--\n" content))

(defn package-content
  [root id]
  {:status 200 :body (package-header (package-file root id))})

(defn package-repository [root]
  (fn [req] (cond
              (= (-> req :query-string) "md5") (id-handler (partial package-info root))
              (constantly true) (id-handler (partial package-content root)))))
