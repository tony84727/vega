(ns vega.grpc
  (:import [
            com.github.tony84727.vega
            DebuggingGrpc$DebuggingImplBase
            DebugConsole$Output]))

(defn debug-text [text] (-> (DebugConsole$Output/newBuilder)
                            (.setContent text)
                            (.build)))



(defn debugging-service [] (proxy
                               [DebuggingGrpc$DebuggingImplBase] []
                             (listen [_ _ response] (-> response
                                                        (.onNext (debug-text "hi"))
                                                        (.onComplete)))))
(def grpc-port 5000)
