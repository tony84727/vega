(defproject vega "0.1.0-SNAPSHOT"
  :description "Centralized Minecraft base controller"
  :url "https://github.com/tony84727/vega"
  :license {:name "GNU AFFERO GENERAL PUBLIC LICENSE"
            :Url "https://www.gnu.org/licenses/agpl-3.0.en.html"}
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [http-kit "2.3.0"]
                 [compojure "1.6.1"]
                 [com.taoensso/timbre "4.10.0"]
                 [com.google.protobuf/protobuf-java "3.12.2"]
                 [org.apache.tomcat/annotations-api "6.0.53"]
                 [io.grpc/grpc-netty-shaded "1.30.2" :exclusions [io.grpc/grpc-core,io.grpc/grpc-api]]
                 [io.grpc/grpc-protobuf "1.30.2"]
                 [io.grpc/grpc-stub "1.30.2"]]
  :plugins [[lein-protoc "0.5.0"]]
  :protoc-version "3.12.3"
  :protoc-grpc {:version "1.30.1"}
  :java-source-paths ["target/default/generated-sources/protobuf"]
  
  :main ^:skip-aot vega.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
