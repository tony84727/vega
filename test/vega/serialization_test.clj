(ns vega.serialization-test
  (:require [clojure.test :refer :all]
            [vega.serialization :refer :all]))

(deftest test-serialize
  (testing "serialize an array"
    (is (= "{1,2,3,4}" (serialize '(1 2 3 4))))))
