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

(defn insert-migration-id-table-query [keyspace id]
  (list (alia/prepare session (format "INSERT INTO %s.ragtime_migrations (id, created_at) VALUES (?, toUnixTimestamp(now()))" keyspace)) {:values [id]}))

(defn list-migration-id-query [keyspace] (format "SELECT id FROM %s.ragtime_migrations" keyspace))

(defn use-keyspace [keyspace] (format "USE %s" keyspace))

(defn execute-statements [session keyspace statements]
  (alia/execute session (use-keyspace keyspace))
  (doseq [statement statements] (alia/execute session statement)))

(defrecord CassandraDataStore [session keyspace-name]
  rgp/DataStore
  (add-migration-id [_ id]
    (ensure-migration-table! keyspace-name)
    (alia/execute session (insert-migration-id-table-query keyspace-name id)))
  (remove-migration-id [_ id]
    (ensure-migration-table! keyspace-name)
    (apply alia/execute session (insert-migration-id-table-query)))
  (applied-migration-ids [_]
    (map :id (alia/execute session (list-migration-id-query keyspace-name)))))

(defrecord CassandraMigration [id up down]
  rgp/Migration
  (id [_] id)
  (run-down! [_ store]
    (let [keyspace (:keyspace-name store)
          session (:session store)]
      (execute-statements session keyspace down)))
  (run-up! [_ store]
    (let [keyspace (:keyspace-name store)
          session (:session store)]
      (execute-statements session keyspace up))))
