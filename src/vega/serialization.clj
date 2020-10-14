(ns vega.serialization
  (:require [clojure.string :as cs]))

(declare serialize-fn)
(declare serialize)

(def separator ", ")

(defn- serialize-list
  [data]
  #(str "{" (cs/join separator (map serialize data)) "}"))

(defn- serialize-map
  [m]
  #(str "{" (cs/join separator (map (fn [[k v]] (str k " = " (serialize v))) (seq m))) "}"))

(defn- serialize-fn
  [data]
  (cond
    (map? data) (serialize-map data)
    (list? data) (serialize-list data)
    (vector? data) (serialize-list data)
    (string? data) (str "\"" data "\"")
    (constantly true) data))

(defn serialize
  [data]
  (trampoline serialize-fn data))
