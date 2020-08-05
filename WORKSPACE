load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_clojure",
    url = "https://github.com/simuons/rules_clojure/archive/cf159a60d763b14783a91eb2129a4cde50e03f0c.zip",
    sha256 = "1d8ba11d1f9725cc4ac20184fadf200e216a19178d5a3d4c8b745abb0f21bc8a",
    strip_prefix = "rules_clojure-cf159a60d763b14783a91eb2129a4cde50e03f0c",
)
load("@rules_clojure//:runtime.bzl", "clojure_runtime")
clojure_runtime()
register_toolchains("@rules_clojure//rules:clojure_toolchain")