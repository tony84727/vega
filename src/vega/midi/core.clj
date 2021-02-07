(ns vega.midi.core
  (:require [clojure.java.io :as io])
  (:import [javax.sound.midi MidiSystem MidiEvent Track MidiMessage MetaMessage ShortMessage Sequence]))

(defn- read-midi!
  [path]
  (MidiSystem/getSequence (io/file path)))
(defn- events
  [^Track track]
  (let [count (.size track)]
    (map (fn [i] (.get track i)) (range 0 count))))
(defn- get-message
  [^MidiEvent e]
  (.getMessage e))
(defn- message-summary [^MidiMessage m]
  (condp instance? m
    MetaMessage "meta"
    ShortMessage (.getCommand m)
    (type m)))
(defn- control-message-summary
  [^ShortMessage m]
  (let [control-number (.getData1 m)
        value (.getData2 m)]
    (format "control change %02x => %d" control-number value)))
(defn- program-change-message-summary [^ShortMessage m]
  (let [data1 (.getData1 m)
        data2 (.getData2 m)]
    (format "program change %02x %02x" data1 data2)))
(defn- print-message
  [m]
  (when (instance? ShortMessage m)
    (let [command (.getCommand m)]
      (condp = command
        ShortMessage/NOTE_ON (str "NOTE_ON: " (.getData1 m))
        ShortMessage/NOTE_OFF (str "NOTE_OFF: " (.getData2 m))
        ShortMessage/CONTROL_CHANGE (control-message-summary m)
        ShortMessage/PROGRAM_CHANGE (program-change-message-summary m)
        command))))
(defn- get-tracks [^Sequence midi-seq]
  (.getTracks midi-seq))
(defn- get-track [^Sequence midi-seq n]
  (nth (get-tracks midi-seq) n))
(defn- sequence-summary [^Sequence seq]
  {:tick-length (.getTickLength seq)
   :resolution (.getResolution seq)})
(defn- t1
  []
  (map (comp print-message get-message) (events (get-track f 3))))
