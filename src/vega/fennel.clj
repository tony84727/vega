(ns vega.fennel
  (:require [resauce.core :as resauce]
            [clojure.java.shell :as shell]))

(defn transpile-file
  "transpile fennel source file to lua"
  [path]
  (let [result (shell/sh "fennel" "--compile" path)]
    (when-not (empty? (:err result)) (throw (ex-info "compile error" result)))
    (:out result)))
