use std::pin::Pin;

use serde::{Deserialize, Serialize};
use thiserror::Error;
use warp::{
    http::StatusCode,
    path::{param, tail, Tail},
    reject::Reject,
    reply::json,
    Filter, Future, Rejection, Reply,
};

use crate::config::ServerConfig;
pub mod directory;
pub mod middleware;

#[derive(Serialize, Deserialize, Debug)]
pub struct FileMetadata {
    #[serde(skip_serializing)]
    pub path: String,
    pub checksum: String,
    #[serde(rename = "installPath")]
    pub install_path: String,
}

#[derive(Serialize, Deserialize)]
pub struct HttpFileMetadata {
    #[serde(flatten)]
    metadata: FileMetadata,
    url: String,
}

impl HttpFileMetadata {
    fn new(metadata: FileMetadata, external_url: &str, package: &str) -> Self {
        let url = format!("{}/packages/{}/{}", external_url, package, metadata.path);
        Self { metadata, url }
    }
}

#[derive(Serialize, Deserialize)]
struct Manifest {
    checksum: String,
    files: Vec<FileMetadata>,
}

#[derive(Error, Debug)]
pub enum RepositoryError {
    #[error("not found")]
    NotFound,
    #[error("other {0}")]
    Other(#[from] anyhow::Error),
}

impl Reject for RepositoryError {}

impl Into<Box<dyn Reply>> for RepositoryError {
    fn into(self) -> Box<dyn Reply> {
        Box::new(match self {
            Self::NotFound => StatusCode::NOT_FOUND,
            Self::Other(_) => StatusCode::INTERNAL_SERVER_ERROR,
        })
    }
}

pub trait Repository {
    fn list_files(&self, package: &str) -> Result<Vec<FileMetadata>, RepositoryError>;
    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError>;
    fn get_metadata(&self, package: &str, path: &str) -> Result<FileMetadata, RepositoryError>;
}

pub struct HttpRepository<R>
where
    R: Repository + Send + Clone,
{
    repository: R,
    external_url: String,
}

impl<R> HttpRepository<R>
where
    R: Repository + Sync + Send + Clone,
{
    pub fn new(repository: R, config: &ServerConfig) -> Self {
        Self {
            repository,
            external_url: config.external_url.clone().unwrap(),
        }
    }
    pub fn filters(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        warp::get().and(
            self.manifest()
                .recover(Self::recover_repository_error("manifest"))
                .or(self
                    .get_content()
                    .recover(Self::recover_repository_error("get_content"))),
        )
    }
    fn manifest(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        let repository = self.repository.clone();
        let external_url = self.external_url.clone();
        warp::path!("packages" / String / "manifest").and_then(move |package: String| {
            let repository = repository.clone();
            let external_url = external_url.clone();
            async move {
                repository
                    .list_files(&package)
                    .map(|metadata| {
                        metadata
                            .into_iter()
                            .map(|metadata| {
                                HttpFileMetadata::new(metadata, &external_url, &package)
                            })
                            .collect::<Vec<HttpFileMetadata>>()
                    })
                    .map(|result| json(&result))
                    .map_err(warp::reject::custom)
            }
        })
    }
    fn get_content(&self) -> impl Filter<Extract = impl Reply, Error = warp::Rejection> + Clone {
        let repository = self.repository.clone();
        warp::get()
            .and(warp::path("packages"))
            .and(param::<String>())
            .and(tail())
            .and_then(move |package: String, path: Tail| {
                let repository = repository.clone();
                async move {
                    repository
                        .get_file(&package, path.as_str())
                        .map_err(warp::reject::custom)
                }
            })
    }
    fn recover_repository_error(
        name: &str,
    ) -> impl Fn(
        Rejection,
    ) -> Pin<Box<dyn Future<Output = Result<StatusCode, Rejection>> + Sync + Send>>
           + Clone {
        let name = name.to_owned();
        move |rejection: Rejection| {
            let name = name.clone();
            Box::pin(async move {
                match rejection.find::<RepositoryError>() {
                    Some(RepositoryError::NotFound) => Ok(StatusCode::NOT_FOUND),
                    Some(RepositoryError::Other(inner)) => {
                        log::error!("{} error: {:?}", name, inner);
                        Ok(StatusCode::INTERNAL_SERVER_ERROR)
                    }
                    _ => Err(rejection),
                }
            })
        }
    }
}
