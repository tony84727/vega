(ns vega.file
  (:require [clojure.java.io :as io]
            [clojure.string :as cs]))

(defn file-extension
  "return file extension without period"
  [path]
  (when path (second (re-find #"\.([^\\]+)$" path))))

(defn exists? [path] (.exists (io/file path)))

(defn replace-extension
  "replace file extension"
  [path ext]
  (cs/replace path #"(.+)\.(\S+)$" (str "$1." ext)))
