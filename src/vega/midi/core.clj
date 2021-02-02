(ns vega.midi.core
  (:require [clojure.java.io :as io])
  (:import [javax.sound.midi MidiSystem MidiEvent Track MidiMessage MetaMessage ShortMessage]))

(defn- events
  [^Track track]
  (let [count (.size track)]
    (map (fn [i] (.get track i)) (range 0 count))))

(def ^:private to-message (map (fn [^MidiEvent e] (.getMessage e))))
(def ^:private summary (map (fn [^MidiMessage m] (condp instance? m
                                                   MetaMessage "meta"
                                                   ShortMessage (.getCommand m)
                                                   (type m)))))


