(local computer (require "computer"))
(local internet (require "internet"))
(local serialization (require "serialization"))
(let [data {:address (computer.address)
            :freeMemory (computer.freeMemory)
            :energy (computer.energy)
            :maxEnergy (computer.maxEnergy)
            :devices (computer.getDeviceInfo)}]
  (internet.request "http://localhost:8080/log" (serialization.serialize data) {} "POST"))
