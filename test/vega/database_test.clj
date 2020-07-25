(ns vega.database-test
  (:require [clojure.test :refer :all]
            [vega.database :refer :all]))

(deftest test-tokenize-sql-statement
  (testing "tokenize sql statements"
    (is (= ["SELECT ...", "DELETE ..."]
           (tokenize-sql-statement "SELECT ...;\nDELETE ..."))))
  (testing "strip out empty lines"
    (is (= ["SELECT ...", "DELETE ..." "ALTER TABLE"]
           (tokenize-sql-statement "SELECT ...;\nDELETE ...;\nALTER TABLE;\n;;")))))
