use std::path::PathBuf;
use std::sync::Arc;
use vega::package::directory::DirectoryRepository;
use vega::package::middleware::{compile_fennel, RepositoryWithMiddleware};
use vega::package::HttpRepository;

#[tokio::main]
async fn main() {
    let repository = DirectoryRepository::new(PathBuf::new().join("packages"));
    let mut with_middleware = RepositoryWithMiddleware::new(repository);
    with_middleware.apply(Box::new(compile_fennel));

    let http = HttpRepository::new(Arc::new(with_middleware));

    warp::serve(http.filters())
        .run(([127, 0, 0, 1], 3030))
        .await;
}
