(ns vega.grpc
  (:import [
            com.github.tony84727.vega
            DebuggingGrpc$DebuggingImplBase
            DebugConsole$Output]))

(defn debug-text [text] (-> (DebugConsole$Output/newBuilder)
                            (.setMessage text)
                            (.build)))

(reify DebuggingImplBase
  (listen [this _ response] (.onNext response (debug-text "hi"))))
