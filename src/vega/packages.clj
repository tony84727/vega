(ns vega.packages
  (:require [taoensso.timbre :as l]
            [vega.fennel :as fennel]
            [vega.file :as f]
            [vega.serialization :as vs]
            [clojure.java.io :as io]
            [clojure.string :as cs])
  (:import [java.security MessageDigest]))

(defn md5 [^String s]
  (let [algorithm (MessageDigest/getInstance "MD5")
        raw       (.digest algorithm (.getBytes s))]
    (format "%032x" (BigInteger. 1 raw))))

(defn id-handler
  "wrapper for handlers that only want the id of the requesting package"
  [handler]
  (fn [req] (handler (-> req :params :*))))

(defn package-header [content] (str "--[[" (md5 content) "]]--"))

(defn find-paths [paths]
  (loop [to-try paths]
    (when-not (empty? to-try)
      (let [path (first to-try)
            exists (f/exists? path)]
        (if exists path (recur (rest to-try)))))))

(defn get-source [root id]
  (let [path (str root id)
        ext (f/file-extension path)]
    (when path
      (let [source (slurp path)]
        (if (= "fnl" ext)
          [source (fennel/transpile-file path)]
          [source source])))))

(defn package-info
  "serve package info (e.g) md5 hash, last modified. print it out in body beause it's not convenient to read headers from openComputers"
  [root id] (let [[s] (get-source root id)] {:status (if s 200 404) :body (when s (md5 s))}))

(defn package-content-handler
  [root id]
  (let [[source compiled] (get-source root id)]
    {:status (if compiled 200 404)
     :body (when compiled (str (package-header source) "\n" compiled))}))

(defn- trim-prefix
  [prefix s]
  (cs/replace
   s
   (re-pattern (str "^\\Q" prefix "\\E"))
   ""))

(defn generate-manifest
  [package trim-path]
  (comp
   (filter #(.isFile %))
   (map #(.getPath %))
   (map (fn [path]
          (let [relative-path (trim-prefix trim-path path)]
            (list
             (md5 (slurp path))
             (str "packages/" package "/" relative-path)
             (if (= "fnl" (f/file-extension relative-path))
               (f/replace-extension relative-path "lua")
               relative-path)))))
   (map (fn [[checksum url install-path]]
          {"checksum" checksum
           "url" url
           "installPath" install-path}))))

(defn- manifest
  [root id]
  (let [dir-path (str root id "/")
        dir (io/file dir-path)]
    (if (.exists dir)
      {:status 200
       :body
       (let [results (transduce
                      (generate-manifest id dir-path)
                      conj
                      (file-seq dir))
             checksum (md5 (vs/serialize results))]
         (vs/serialize {"checksum" checksum
                        "files" results}))
       :headers
       {"content-type" "text/plain"}}
      {:status 404 :body (str "package " id " doesn't exist")})))

(defn service [root]
  (fn [req] (case (:query-string req)
              "md5" (id-handler (partial package-info root))
              "manifest" (id-handler (partial manifest root))
              (id-handler (partial package-content-handler root)))))
