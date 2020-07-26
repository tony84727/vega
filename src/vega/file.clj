(ns vega.file)

(defn file-extension
  "return file extension without period"
  [path]
  (second (re-find #"\.([^\\]+)$" path)))
