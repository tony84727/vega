# Lua Script Repository

The Lua script repository exposes package manifests and package files over
HTTP.

## Package Manifest

```text
GET /packages/{package}?manifest
```

Returns a JSON manifest for `{package}`.

The query string must be exactly `manifest`.

Response body:

```json
{
  "checksum": "<package-checksum>",
  "files": [
    {
      "checksum": "<file-checksum>",
      "installPath": "<client-install-path>",
      "url": "packages/{package}/{path}"
    }
  ]
}
```

Contract:

- `checksum` identifies the package version represented by the manifest.
- `files[].checksum` identifies the file version.
- `files[].installPath` is the path where the client should install the file.
- `files[].url` is the relative URL used to download the file.
- Fennel source files are installed as Lua files, so `.fnl` sources appear with
  `.lua` install paths.

## Package File

```text
GET /packages/{package}/{path...}
```

Returns the requested package file content.

Contract:

- `{package}` is the first path segment after `/packages/`.
- `{path...}` is the file path inside that package.
- Fennel source file downloads return Lua content.
- Returned Lua content starts with a checksum comment:

```lua
--[[<file-checksum>]]--
```

## Status Codes

- `200 OK`: request succeeded.
- `404 Not Found`: package or file was not found.
- `500 Internal Server Error`: repository could not produce the requested
  response.

## Notes

- Repository endpoints are read-only.
- Package file URLs in manifests are relative to the server root.
