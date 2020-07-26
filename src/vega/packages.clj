(ns vega.packages
  (:require [taoensso.timbre :as l]
            [vega.fennel :as fennel]
            [vega.file :as f])
  (:import [java.security MessageDigest]))

(defn md5 [^String s]
  (let [algorithm (MessageDigest/getInstance "MD5")
        raw       (.digest algorithm (.getBytes s))]
    (format "%032x" (BigInteger. 1 raw))))

(defn id-handler
  "wrapper for handlers that only want the id of the requesting package"
  [handler]
  (fn [req] (handler (-> req :params :id))))

(defn package-header [content] (str "--[[" (md5 content) "]]--\n" content))

(defn find-paths [paths]
  (loop [to-try paths]
    (when-not (empty? to-try)
      (let [path (first to-try)
            exists (f/exists? path)]
        (if exists path (recur (rest to-try)))))))

(defn get-source [root id]
  (let [path (find-paths (map #(str root id %) [".lua" ".fnl"]))
        ext (f/file-extension path)]
    (when path
      (if (= "fnl" ext) (fennel/transpile-file path) (slurp path)))))

(defn package-info
  "serve package info (e.g) md5 hash, last modified. print it out in body beause it's not convenient to read headers from openComputers"
  [root id] (let [s (get-source root id)] {:status (if s 200 404) :body (when s (md5 s))}))

(defn package-content-handler
  [root id]
  (let [source (get-source root id)]
    {:status (if source 200 404)
     :body (when source (package-header source))}))

(defn package-repository [root]
  (fn [req] (cond
              (= (-> req :query-string) "md5") (id-handler (partial package-info root))
              (constantly true) (id-handler (partial package-content-handler root)))))
