(local internet (require "internet"))
(local filesystem (require "filesystem"))
(local serialization (require "serialization"))
(local loader-package-id "loader")

(fn load-vega-config
  []
  (local (file err) (filesystem.open "/home/vega.host"))
  (if (= nil err)
      (let [host (file:read 1024)]
        (file:close)
        host)
      ""))

(var vega "http://localhost:8080")
(local config-host (load-vega-config))
(if (> (string.len config-host) 0)
    (set vega config-host))
(fn package-url-with-query-string
  [repository id query-string]
  (let [url (.. repository id)]
    (if (> (string.len query-string) 0)
        (.. url "?" query-string)
        url)))
(local package-repository (.. vega "/packages/"))
(fn package-url [repository id]
  (package-url-with-query-string repository id ""))
(fn ensure-directory!
  [dir]
  (filesystem.makeDirectory dir))
(fn http-get [url]
  (let [handle (internet.request url)]
    (var done false)
    (var response "")
    (while (not done)
      (local buffer (handle.read))
      (if (= nil buffer)
          (set done true)
          (set response (.. response buffer))))
    response))
(fn spit
  [path content]
  (local (file err) (io.open path "w"))
  (if file
      (do
        (file:write content)
        (file:close)
        nil)
      err))
(fn slurp
  [path]
  (local (file err) (io.open path))
  (if file
      (do
        (var buffer "")
        (var read (file:read))
        (while (not (= read nil))
          (set buffer (.. buffer read))
          (set read (file:read)))
        (file:close)
        (values buffer nil))
      (values nil err)))
(fn http-download-to
  [url path]
  (filesystem.makeDirectory (filesystem.path path))
  (let [result (spit path (http-get url))]
    (when (~= nil result)
      (print err))))
(fn get-manifest
  [pkg]
  (let [manifest (http-get (package-url-with-query-string package-repository pkg "manifest"))]
    (serialization.unserialize manifest)))
(fn local-manifest-path
  [pkg]
  (.. "/home/.loader/manifests/" pkg ".manifest"))
(fn get-local-manifest
  [pkg]
  (let [manifest-path (local-manifest-path pkg)
        (manifest err) (slurp manifest-path)]
    (when (= err nil)
        (serialization.unserialize manifest))))
(fn ensure-loader-dir!
  []
  (ensure-directory! "/home/.loader"))
(fn path-table
  [list]
  (var index [])
  (each [_ k (pairs list)]
    (tset index k.installPath k))
  index)
(fn keys
  [t]
  (var k-list [])
  (each [k (pairs t)]
    (table.insert k-list k))
  k-list)
(fn diff-table
  [a b]
  (let [a-keys (keys a)]
    (var special [])
    (each [_ ak (pairs a-keys)]
      (when (= nil (. b ak))
          (table.insert special (. a ak))))
    special))
(fn get-patch-list
  [desired current]
  (if (= nil desired)
      (values {} current)
      (if (= nil current)
          (values desired {})
          (do
            (var to-patch [])
            (let [desired-paths (path-table desired)
                  current-paths (path-table current)]
              (each [i f (pairs desired-paths)]
                (let [current-state (. current-paths i)
                      current-checksum (and (~= nil current-state) current-state.checksum)]
                  (when (~= current-checksum f.checksum)
                    (table.insert to-patch f)))
                )
              (values to-patch (diff-table current-paths desired-paths)))))))
(fn patch-files!
  [entries]
  (each [_ entry (ipairs entries)]
    (let [url (.. vega "/" entry.url)
          install-path entry.installPath]
      (print (.. url " => " install-path))
      (ensure-directory! (filesystem.path (filesystem.concat "/home" install-path)))
      (http-download-to url install-path))))
(fn delete-files!
  [entries]
  (each [_ entry (ipairs entries)]
    (print (.. "delete stalled file: " entry.installPath))
    (os.remove (filesystem.concat "/home" entry.installPath))))
(fn update-local-manifest!
  [pkg manifest]
  (local manifest-path (local-manifest-path pkg))
  (ensure-directory! (filesystem.path manifest-path))
  (let [result (spit manifest-path (serialization.serialize manifest))]
    (when result
      (print "failed to update manifest")
      (print result))))

(fn ensure-package
  [pkg]
  (print "checking manifest ....")
  (local local-manifest (get-local-manifest pkg))
  (print (.. "local checksum: " (if local-manifest
                                    local-manifest.checksum
                                    "missing")))
  (local remote-manifest (get-manifest pkg))
  (if (= nil remote-manifest)
      (print (.. "package " pkg " doesn't exist on the vega"))
      (do
        (print (.. "remote checksum: " remote-manifest.checksum))
        (when (or (= nil local-manifest) (not (= local-manifest.checksum remote-manifest.checksum)))
          (print (.. "package " pkg " needs update"))
          (let [(to-patch to-delete) (get-patch-list remote-manifest.files (and local-manifest local-manifest.files))]
            (patch-files! to-patch)
            (delete-files! to-delete))
          (update-local-manifest! pkg remote-manifest)))))
(ensure-loader-dir!)
(ensure-package "loader")
(fn delete-manifest!
  [pkg]
  (os.remove (local-manifest-path pkg)))
(fn uninstall-package
  [pkg]
  (local manifest (get-local-manifest pkg))
  (if (= nil manifest)
      (print (.. "package " pkg " is not installed"))
      (do
        (delete-files! manifest.files)
        (delete-manifest! pkg)
        (print (.. "package " pkg " uninstalled")))))
(local args [...])
(match (. args 1)
  "ensure" (ensure-package (. args 2))
  "uninstall" (uninstall-package (. args 2))
  (print "unknown command"))
