(ns vega.database
  (:require [clojure.core.reducers :as r]
            [qbits.alia :as alia]
            [ragtime.repl :as rg]
            [ragtime.protocols :as rgp]))

(def cluster (alia/cluster {:contact-points ["localhost"]}))

(defn create-keyspace!
  "create a keyspace with SimpleStrategy with replication factor 1"
  [session keyspace] (alia/execute
                      session
                      (format "CREATE KEYSPACE %s WITH replication = {'class':'SimpleStrategy', 'replication_factor': 1}" keyspace)))
(defn create-migration-table-query [keyspace]
  (format "CREATE TABLE IF NOT EXISTS %s.ragtime_migrations (id varchar, created_at timestamp, PRIMARY KEY (id))" keyspace))
(defn ensure-migration-table! [session keyspace]
  (alia/execute session
                (create-migration-table-query keyspace)))

(defrecord CassandraDataStore [session keyspace-name]
  rgp/DataStore
  (add-migration-id [_ id]
    (ensure-migration-table! keyspace-name)
    (alia/execute
     session
     (format "INSERT INTO %s.migrations (id) VALUES (?)" keyspace-name) {:values [id]}))
  (remove-migration-id [_ id]
    (ensure-migration-table! keyspace-name)
    (alia/execute
     session
     "DELETE FROM %s.migrations WHERE id = ?" id))
  (applied-migration-ids [_]
    ()))

