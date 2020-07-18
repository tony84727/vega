local computer = require("computer")
local internet = require("internet")
local serialization = require("serialization")

local data = {
  address = computer.address(),
  freeMemory = computer.freeMemory(),
  energy = computer.energy(),
  maxEnergy = computer.maxEnergy(),
  devices = serialization.serialize(computer.getDeviceInfo())
}
internet.request("http://localhost:8080/log", data, {}, "POST")