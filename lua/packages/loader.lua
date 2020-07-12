local internet = require("internet")
local filesystem = require("filesystem")
local loaderPackageID = "loader"

function loadVegaConfig()
  if filesystem.exists("/home/vega.host") then
    local file, err = filesystem.open("/home/vega.host")
    if err ~= nil then
      print("failed to load vega.host configuration")
      return ""
    end
    host = file:read(1024)
    file:close()
    return host
  end
  return ""
end

local vega = "http://localhost:8080/"
local configHost = loadVegaConfig()
if string.len(configHost) > 0 then
  vega = configHost
end

function packageURLWithQueryString(repository, id, queryString)
  local url = repository  .. id
  if string.len(queryString) > 0 then
    url = url .. "?" .. queryString
  end
  return url
end
local packageRepository = vega .. "packages/"
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

function getChecksum(path)
  local file, err = filesystem.open(path)
  if err ~= nil then
    print("unable to access " .. path .. " " .. err)
    return ""
  end
  local header = file:read(50)
  if header == nil then
    return ""
  end
  file:close()
  local checksumEnd = string.find(header, "]")
  if checksumEnd == nil then
    return ""
  else
    checksumEnd = checksumEnd - 1
  end
  return string.sub(header, 5, checksumEnd)
end

function checkPackage(package)
  local packageFile = "/home/bin/" .. package .. ".lua"
  local exists = filesystem.exists(packageFile)
  if exists then
    local remoteChecksum = getPackageMD5("loader")
    local localChecksum = getChecksum(packageFile)
    print("remote checksum: " .. remoteChecksum)
    print("local checksum: " .. localChecksum)
    if remoteChecksum == localChecksum then
      print("update-to-date")
      return
    end
    print("new version of " .. package .. " available, updating ... ")
    -- backup
    local success = filesystem.copy("/home/bin/" .. package .. ".lua", "/home/bin/" .. package .. ".old.lua")
    if not success then
      print("failed to backup original version of " .. package)
      return
    end
  end
  fetchPackage(package)
  print("done")
end

function selfCheck()
  checkPackage("loader")
end

selfCheck()

local args = {...}
if args[1] ~= nil then
  checkPackage(args[1])
end
