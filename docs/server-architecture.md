# Server Architecture

The server is a single Rust HTTP process built with Warp and Tokio.

## HTTP Stack

- Runtime: Tokio (`#[tokio::main]`)
- HTTP framework: Warp
- Logging: `env_logger` with Warp request logging under the `api` target
- Server entrypoint: `src/bin/server.rs`

`src/bin/server.rs` composes the Warp filters for package serving and static
music serving, then starts the HTTP server.

## Bind Address

The server listens on localhost:

```text
127.0.0.1:3030
```

The bind address is currently hard-coded in `src/bin/server.rs`.

## Routes

The running server exposes routes for:

- Lua script package repository access under `/packages`
- Static music files under `/music`

Package repository behavior is documented separately in
[`lua-script-repository.md`](lua-script-repository.md).
