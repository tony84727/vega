use std::sync::Arc;
use vega::{
    package::{
        directory::DirectoryRepository,
        middleware::{compile_fennel, insert_checksum_header, RepositoryWithMiddleware},
        HttpRepository,
    },
    test_utils::{create_dummy_files, temp_dir::TemporaryDirectory},
};
use warp::hyper::StatusCode;
#[tokio::test]
async fn test_http_repository() {
    let test_dir = TemporaryDirectory::new_random().unwrap();
    create_dummy_files(test_dir.root(), &["loader/bin/loader.fnl"]);
    let repository = DirectoryRepository::new(test_dir.root().to_owned());
    let mut with_middleware = RepositoryWithMiddleware::new(repository);
    with_middleware.apply(Box::new(compile_fennel));
    with_middleware.apply(Box::new(insert_checksum_header));

    let http = HttpRepository::new(
        Arc::new(with_middleware),
        &vega::config::ServerConfig {
            external_url: Some("https://localhost:3030".to_string()),
        },
    );
    let filters = http.filters();
    let reply = warp::test::request()
        .path("/packages/loader")
        .reply(&filters)
        .await;
    assert_eq!(StatusCode::NOT_FOUND, reply.status());
}
