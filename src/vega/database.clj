(ns vega.database
  (:import [com.datastax.oss.driver.api.core CqlSession]
           [com.datastax.oss.driver.api.core.cql SimpleStatement])
  (:require [clojure.core.reducers :as r]
            [ragtime.repl :as rg]
            [ragtime.protocols :as rgp]))

(defn new-default-session [] (.build (CqlSession/builder)))
(defn simple-statement
  "build SimpleStatement. Can escape parameters."
  [query & positional-parameters]
  (-> (SimpleStatement/builder query) (.addPositionalValues positional-parameters) (.build)))

(defn query
  ([session statement] (.execute session statement))
  ([session statement & parameters] (query session (simple-statement statement parameters))))

(defn create-keyspace
  "create simple keyspace"
  [name]
  (format "CREATE KEYSPACE %s WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 0}" name))
(defonce session (atom nil))

(defn init-session [] (reset! session (new-default-session)))

(defn create-migration-table [keyspace]
  (format "CREATE TABLE IF NOT EXISTS %s.migrations (id text PRIMARY KEY)" keyspace))

(defn ensure-migration-table-exists [session keyspace-name]
  (query session (create-migration-table keyspace-name)))

(defn insert-into-table [table fields values]
  (simple-statement
   (format "INSERT INTO %s (?) VALUES (?)" table)
   fields values))

(defrecord CassandraDataStore [session keyspace-name]
  rgp/DataStore
  (add-migration-id [_ id]
    (ensure-migration-table-exists session keyspace-name)
    (query
     session
     (format "INSERT INTO %s.migrations (id) VALUES (?)" keyspace-name) id))
  (remove-migration-id [_ id]
    (ensure-migration-table-exists session keyspace-name)
    (query
     session
     "DELETE FROM %s.migrations WHERE id = ?" id))
  (applied-migration-ids [_]
    ()))

