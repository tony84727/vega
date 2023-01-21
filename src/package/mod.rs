use serde::{Deserialize, Serialize};
use thiserror::Error;
use warp::{
    http::StatusCode,
    path::{param, tail, Tail},
    reply::json,
    Filter, Reply,
};
pub mod directory;
pub mod middleware;

#[derive(Serialize, Deserialize, Debug)]
pub struct File {
    pub checksum: String,
    #[serde(rename = "installPath")]
    pub install_path: String,
}

#[derive(Serialize, Deserialize)]
struct Manifest {
    checksum: String,
    files: Vec<File>,
}

#[derive(Error, Debug)]
pub enum RepositoryError {
    #[error("not found")]
    NotFound,
    #[error("other {0}")]
    Other(anyhow::Error),
}

impl Into<Box<dyn Reply>> for RepositoryError {
    fn into(self) -> Box<dyn Reply> {
        Box::new(match self {
            Self::NotFound => StatusCode::NOT_FOUND,
            Self::Other(_) => StatusCode::INTERNAL_SERVER_ERROR,
        })
    }
}

pub trait Repository {
    fn list_files(&self, package: &str) -> Result<Vec<File>, RepositoryError>;
    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError>;
}

pub struct HttpRepository<R>
where
    R: Repository + Send + Clone,
{
    repository: R,
}

impl<R> HttpRepository<R>
where
    R: Repository + Send + Clone,
{
    pub fn new(repository: R) -> Self {
        Self { repository }
    }
    pub fn filters(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        warp::get().and(self.manifest().or(self.get_content()))
    }
    fn manifest(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        let repository = self.repository.clone();
        warp::path!("packages" / String / "manifest").map(move |package: String| {
            let reply: Box<dyn Reply> = match repository.list_files(&package) {
                Ok(files) => Box::new(json(&files)),
                Err(err) => err.into(),
            };
            reply
        })
    }
    fn get_content(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        let repository = self.repository.clone();
        warp::get()
            .and(warp::path("packages"))
            .and(param::<String>())
            .and(tail())
            .map(move |package: String, path: Tail| {
                let reply: Box<dyn Reply> = match repository.get_file(&package, path.as_str()) {
                    Ok(content) => Box::new(content),
                    Err(err) => err.into(),
                };
                reply
            })
    }
}
