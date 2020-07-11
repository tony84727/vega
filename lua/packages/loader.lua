local internet = require("internet")
local filesystem = require("filesystem")
local loaderPackageID = "loader"
local vega = "http://localhost:8080/"
local packageRepository = vega .. "packages/"

function packageURLWithQueryString(repository, id, queryString)
  local url = repository  .. id
  if string.len(queryString) > 0 then
    url = url .. "?" .. queryString
  end
  return url
end

function packageURL(repository, id)
  return packageURLWithQueryString(repository, id, '')
end

function httpGet(url)
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
  return response
end

function httpDownloadTo(url, path)
  response = httpGet(url)
  filesystem.makeDirectory(filesystem.path(path))
  local file, err = io.open(path, "w")
  if err ~= nil then
    print(err)
  end
  file:write(response)
  file:close()
end

function fetchPackage(package)
  httpDownloadTo(packageURL(packageRepository, package), "/home/bin/" .. package .. ".lua")
end

function getPackageMD5(id)
  return httpGet(packageURLWithQueryString(packageRepository, id, "md5"))
end

function getCurrentChecksum()
  local file = filesystem.open("/home/bin/loader.lua")
  local header = file:read(50)
  return string.sub(header, 5, string.find(header, "]") - 1)
end

function selfUpdate()
  local success = filesystem.copy("/home/bin/loader.lua", "/home/bin/loader.old.lua")
  if not success then
    print("failed to backup original version")
    return
  end
  fetchPackage("loader")
  print("self update done.")
end

function selfCheck()
  print("starting self-update checking")
  local remoteChecksum = getPackageMD5("loader")
  local localChecksum = getCurrentChecksum()
  print("remote checksum: " .. remoteChecksum)
  print("local checksum: " .. localChecksum)
  if remoteChecksum == localChecksum then
    print("update-to-date")
    return
  end
  print("new version available, updating ... ")
  selfUpdate()
end

selfCheck()