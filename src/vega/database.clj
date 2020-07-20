(ns vega.database
  (:import [com.datastax.oss.driver.api.core CqlSession])
  (:require [clojure.core.reducers :as r]
            [ragtime.repl :as rg]
            [ragtime.protocols :as rgp]))

(defn new-default-session [] (.build (CqlSession/builder)))
(defn query [session statement] (.execute session statement))

(defn create-keyspace
  "create simple keyspace"
  [name]
  (format "CREATE KEYSPACE %s WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 0}" name))
(defonce session (atom (new-default-session)))

(def create-migration-table "CREATE TABLE IF NOT EXISTS migrations")

