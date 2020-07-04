local internet = require("internet")
local filesystem = require("filesystem")
local loaderPackageID = "loader"
local vega = "http://localhost:8080/"
local packageRepository = vega .. "packages/"

function packageURL(repository, id)
  return repository  .. id
end

function httpDownloadTo(url, path)
  local handle = internet.request(url)
  local response = ""
  local it = nil
  while true do
    local buffer = handle.read()
    if buffer == nil then
      break
    end
    response = response .. buffer
  end
  filesystem.makeDirectory(filesystem.path(path))
  local file, err = io.open(path, "w")
  if err ~= nil then
    print(err)
  end
  file:write(response)
  file:close()
end

function fetchPackage(package)
  httpDownloadTo(packageURL(packageRepository, package), "/home/vega/packages/" .. package .. ".lua")
end

function selfCheck(packageRepository)
  print("starting self-update checking")
  print("fetching" .. packageRepository)
  local handle = internet.request()
end

fetchPackage("loader")