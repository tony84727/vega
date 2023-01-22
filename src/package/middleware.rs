use std::sync::Arc;

use crate::fennel;

use super::{FileMetadata, Repository, RepositoryError};

#[derive(Clone)]
pub struct Metadata<'m> {
    pub path: &'m str,
}
pub type Middleware = dyn Fn(Metadata, Vec<u8>) -> Result<Vec<u8>, RepositoryError> + Send + Sync;

pub struct RepositoryWithMiddleware<R>
where
    R: Repository,
{
    repository: R,
    content_middlewares: Vec<Box<Middleware>>,
}

impl<R> RepositoryWithMiddleware<R>
where
    R: Repository,
{
    pub fn new(repository: R) -> Self {
        Self {
            repository,
            content_middlewares: vec![],
        }
    }

    pub fn apply(&mut self, middleware: Box<Middleware>) -> &mut Self {
        self.content_middlewares.push(middleware);
        self
    }
}

impl<R> Repository for RepositoryWithMiddleware<R>
where
    R: Repository,
{
    fn list_files(&self, package: &str) -> Result<Vec<FileMetadata>, RepositoryError> {
        self.repository.list_files(package)
    }

    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError> {
        let mut result = self.repository.get_file(package, path)?;
        let metadata = Metadata { path };
        for middleware in self.content_middlewares.iter() {
            result = middleware(metadata.clone(), result)?;
        }
        Ok(result)
    }
    fn get_metadata(&self, package: &str, path: &str) -> Result<FileMetadata, RepositoryError> {
        self.repository.get_metadata(package, path)
    }
}

impl<R> Repository for Arc<RepositoryWithMiddleware<R>>
where
    R: Repository,
{
    fn list_files(&self, package: &str) -> Result<Vec<FileMetadata>, RepositoryError> {
        (**self).list_files(package)
    }
    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError> {
        (**self).get_file(package, path)
    }
    fn get_metadata(&self, package: &str, path: &str) -> Result<FileMetadata, RepositoryError> {
        (**self).get_metadata(package, path)
    }
}

pub fn compile_fennel(metadata: Metadata, content: Vec<u8>) -> Result<Vec<u8>, RepositoryError> {
    if !metadata.path.ends_with(".fnl") {
        return Ok(content);
    }
    fennel::compile(content).map_err(|err| RepositoryError::Other(err.into()))
}

pub fn insert_header(path: &str, content: Vec<u8>) -> Result<Vec<u8>, RepositoryError> {
    todo!();
}

#[cfg(test)]
mod tests {
    use crate::{
        package::{directory::DirectoryRepository, Repository},
        test_utils::{create_dummy_files, temp_dir::TemporaryDirectory},
    };

    use super::RepositoryWithMiddleware;

    #[test]
    fn test_apply_middleware_to_get_file() {
        let test_dir = TemporaryDirectory::new_random().unwrap();
        create_dummy_files(test_dir.root(), &["loader/bin/loader.fnl"]);
        let directory_repository = DirectoryRepository::new(test_dir.root().to_owned());
        let mut with_middleware = RepositoryWithMiddleware::new(directory_repository);
        with_middleware.apply(Box::new(|_path, _content| {
            Ok(Vec::from(b"middleware overridden".as_slice()))
        }));
        assert_eq!(
            b"middleware overridden",
            with_middleware
                .get_file("loader", "bin/loader.fnl")
                .unwrap()
                .as_slice()
        );
    }
}
