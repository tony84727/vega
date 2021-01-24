(ns vega.database
  (:require             [qbits.alia :as alia]
                        [ragtime.repl :as rg]
                        [ragtime.protocols :as rgp]
                        [resauce.core :as resauce]
                        [clojure.string :as s]))

(def ^:private keyspace-name "vega")

(def get-session!
  (memoize (fn [keyspace-name] (let [config {:contact-points ["localhost"]}]
                                 (alia/session (if keyspace-name (assoc config :session-keyspace keyspace-name)
                                                   config))))))

(defn get-default-session!
  []
  (get-session! keyspace-name))

(defn create-keyspace!
  "create a keyspace with SimpleStrategy with replication factor 1"
  [session keyspace] (alia/execute
                      session
                      (format "CREATE KEYSPACE %s WITH replication = {'class':'SimpleStrategy', 'replication_factor': 1}" keyspace)))
(defn create-migration-table-query [])
(defn- ensure-migration-table! [session]
  (alia/execute session
                "CREATE TABLE IF NOT EXISTS ragtime_migrations (id varchar, created_at timestamp, PRIMARY KEY (id))"))

(defn use-keyspace [keyspace] (format "USE %s" keyspace))

(defn execute-statements [session statements]
  (doseq [statement statements] (alia/execute session statement)))

(defrecord CassandraDataStore [session]
  rgp/DataStore
  (add-migration-id [_ id]
    (ensure-migration-table! session)
    (alia/execute session "INSERT INTO ragtime_migrations (id, created_at) VALUES (?, toUnixTimestamp(now()))" {:values [id]}))
  (remove-migration-id [_ id]
    (ensure-migration-table! session)
    (alia/execute session "DELETE FROM ragtime_migrations WHERE id = ?" {:values [id]}))
  (applied-migration-ids [_]
    (ensure-migration-table! session)
    (map :id (alia/execute session "SELECT id FROM ragtime_migrations"))))

(defrecord CassandraMigration [id up down]
  rgp/Migration
  (id [_] id)
  (run-down! [_ store]
    (let [session (:session store)]
      (execute-statements session down)))
  (run-up! [_ store]
    (let [session (:session store)]
      (execute-statements session up))))

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
       (map (fn [[id files]]
              (let [grouped (into {} (map (fn [entry] (vec (drop 1 entry)))) files)]
                (CassandraMigration. id (get grouped "up") (get grouped "down")))))))

(defn- data-store
  "create a cassandra ragtime datasource"
  []
  (->CassandraDataStore (get-session! keyspace-name)))
(defn migration-config [] {:datastore
                           (data-store)
                           :migrations
                           (load-migrations)})

(def execute! (partial alia/execute (get-session! keyspace-name)))
