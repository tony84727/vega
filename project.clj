(defproject vega "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "GNU AFFERO GENERAL PUBLIC LICENSE"
            :Url "https://www.gnu.org/licenses/agpl-3.0.en.html"}
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [http-kit "2.3.0"]
                 [compojure "1.6.1"]]
  :main ^:skip-aot vega.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
