(ns vega.database
  (:require [clojure.core.reducers :as r]
            [qbits.alia :as alia]
            [ragtime.repl :as rg]
            [ragtime.protocols :as rgp]
            [resauce.core :as resauce]
            [clojure.string :as s]))

(def cluster (alia/cluster {:contact-points ["localhost"]}))
(def keyspace-name "vega")

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

(defn insert-migration-id-table-query [session keyspace id]
  (list (alia/prepare session (format "INSERT INTO %s.ragtime_migrations (id, created_at) VALUES (?, toUnixTimestamp(now()))" keyspace)) {:values [id]}))

(defn delete-migration-id-table-query [session keyspace id]
  (list (alia/prepare session (format "DELETE FROM %s.ragtime_migrations WHERE id = ?" keyspace)) {:values [id]}))

(defn list-migration-id-query [keyspace] (format "SELECT id FROM %s.ragtime_migrations" keyspace))

(defn use-keyspace [keyspace] (format "USE %s" keyspace))

(defn execute-statements [session keyspace statements]
  (alia/execute session (use-keyspace keyspace))
  (doseq [statement statements] (alia/execute session statement)))

(defrecord CassandraDataStore [session keyspace]
  rgp/DataStore
  (add-migration-id [_ id]
    (ensure-migration-table! session keyspace)
    (apply alia/execute session (insert-migration-id-table-query session keyspace id)))
  (remove-migration-id [_ id]
    (ensure-migration-table! session keyspace)
    (apply alia/execute session (delete-migration-id-table-query session keyspace id)))
  (applied-migration-ids [_]
    (map :id (alia/execute session (list-migration-id-query keyspace)))))

(defrecord CassandraMigration [id up down]
  rgp/Migration
  (id [_] id)
  (run-down! [_ store]
    (let [keyspace (:keyspace store)
          session (:session store)]
      (execute-statements session keyspace down)))
  (run-up! [_ store]
    (let [keyspace (:keyspace store)
          session (:session store)]
      (execute-statements session keyspace up))))

(defn sql-file-parts [file]
  (rest  (re-matches #".*?/?([^/.]+).(up|down)\.sql" (str file))))

(defn tokenize-sql-statement [sql]
  (filter (complement empty?) (map s/trim (s/split sql #";"))))

(defn read-sql [file]
  (tokenize-sql-statement (slurp file)))

(defn load-migrations []
  (->> (resauce/resource-dir "migrations")
       (map #(conj (vec (sql-file-parts %)) (read-sql %)))
       (group-by first)
       (vals)
       (map (fn [group] (let [id (first (first group))]
                          (->CassandraMigration id (last (first group)) (last (second group))))))))
(defn datasource
  "create a cassandra ragtime datasource"
  []
  (->CassandraDataStore (alia/connect cluster) keyspace-name))
(defn migration-config [] {:datastore
                           (datasource)
                           :migrations
                           (load-migrations)})
