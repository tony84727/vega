(defproject vega "0.1.0-SNAPSHOT"
  :description "Centralized Minecraft base controller"
  :url "https://github.com/tony84727/vega"
  :license {:name "GNU AFFERO GENERAL PUBLIC LICENSE"
            :Url "https://www.gnu.org/licenses/agpl-3.0.en.html"}
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [org.clojure/core.async "1.2.603"]
                 [http-kit "2.3.0"]
                 [compojure "1.6.1"]
                 [com.taoensso/timbre "4.10.0"]
                 [cc.qbits/alia "4.3.3"]
                 [ragtime "0.8.0"]
                 [resauce "0.1.0"]
                 [clj-commons/clj-yaml "0.7.1"]
                 [org.suskalo/discljord "1.1.1"]]
  :plugins [[lein-cljfmt "0.6.8"]]
  :main ^:skip-aot vega.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
