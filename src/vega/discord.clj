(ns vega.discord
  (:require [clj-yaml.core :as yaml]))

(defn get-token []
  (-> (yaml/parse-string (slurp "config.yml"))
      (:discord)
      (:token)))
