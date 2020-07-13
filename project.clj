(defproject vega "0.1.0-SNAPSHOT"
  :description "Centralized Minecraft base controller"
  :url "https://github.com/tony84727/vega"
  :license {:name "GNU AFFERO GENERAL PUBLIC LICENSE"
            :Url "https://www.gnu.org/licenses/agpl-3.0.en.html"}
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [http-kit "2.3.0"]
                 [compojure "1.6.1"]
                 [com.taoensso/timbre "4.10.0"]
                 [com.google.protobuf/protobuf-java "3.12.2"]]
  :plugins [[lein-protobuf "0.5.0"]]
;;  :protoc-version "3.12.3"
;;  :protoc-grpc {:version "1.30.1"}
  
  :main ^:skip-aot vega.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
