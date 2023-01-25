use std::path::PathBuf;
use std::sync::Arc;
use vega::config::load_server_config;
use vega::package::directory::DirectoryRepository;
use vega::package::middleware::{compile_fennel, insert_checksum_header, RepositoryWithMiddleware};
use vega::package::HttpRepository;
use warp::Filter;

#[tokio::main]
async fn main() {
    env_logger::init();
    let repository = DirectoryRepository::new(PathBuf::new().join("packages"));
    let mut with_middleware = RepositoryWithMiddleware::new(repository);
    with_middleware.apply(Box::new(compile_fennel));
    with_middleware.apply(Box::new(insert_checksum_header));
    let config = load_server_config();

    let http = HttpRepository::new(Arc::new(with_middleware), &config);

    warp::serve(
        http.filters()
            .or(warp::path("music").and(warp::fs::dir("music")))
            .with(warp::log("api")),
    )
    .run(([127, 0, 0, 1], 3030))
    .await;
}
