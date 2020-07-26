(ns vega.file-test
  (:require [vega.file :refer :all]
            [clojure.test :refer :all]))

(deftest test-file-extension
  (testing "return file extension"
    (is (= "lua" (file-extension "resource/becon.lua"))))
  (testing "return nil if no extension"
    (is (nil? (file-extension "")))
    (is (nil? (file-extension "ls")))))
