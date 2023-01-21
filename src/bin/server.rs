use std::path::PathBuf;
use vega::package::directory::DirectoryRepository;
use vega::package::HttpRepository;

#[tokio::main]
async fn main() {
    let repository = DirectoryRepository::new(PathBuf::new().join("packages"));
    let http = HttpRepository::new(repository);

    warp::serve(http.filters())
        .run(([127, 0, 0, 1], 3030))
        .await;
}
