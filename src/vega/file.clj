(ns vega.file
  (:require [clojure.java.io :as io]))

(defn file-extension
  "return file extension without period"
  [path]
  (when path (second (re-find #"\.([^\\]+)$" path))))

(defn exists? [path] (.exists (io/file path)))
