use glob::glob;
use regex::Regex;

use super::{FileMetadata, Repository, RepositoryError};
use md5::Digest;
use std::{
    borrow::Cow,
    io::{self, ErrorKind, Read},
    path::{Path, PathBuf},
};

impl FileMetadata {
    fn from_path_and_install_path<P: AsRef<Path>, S: AsRef<str>>(
        path: P,
        install_path: S,
    ) -> Result<Self, RepositoryError> {
        let content = std::fs::read_to_string(&path).map_err(io_error_to_repository_error)?;
        let mut hasher = md5::Md5::new();
        hasher.update(content);
        Ok(FileMetadata {
            path: install_path.as_ref().to_string(),
            checksum: format!("{:x}", hasher.finalize()),
            install_path: Self::replace_source_extension_to_compiled_extension(
                install_path.as_ref(),
            )
            .to_string(),
        })
    }
    fn replace_source_extension_to_compiled_extension(install_path: &str) -> Cow<str> {
        let pattern = Regex::new(r#"\.fnl$"#).expect("valid regex pattern");
        pattern.replace(install_path, ".lua")
    }
}

#[derive(Clone)]
pub struct DirectoryRepository {
    root: PathBuf,
}

impl DirectoryRepository {
    pub fn new(root: PathBuf) -> Self {
        Self { root }
    }

    fn package_exists(&self, package: &str) -> io::Result<bool> {
        Ok(self.root.join(package).is_dir())
    }

    fn package_root(&self, package: &str) -> PathBuf {
        self.root.join(package)
    }

    fn assert_normal_file<P: AsRef<Path>>(target: P) -> Result<(), RepositoryError> {
        if std::fs::metadata(&target)
            .map_err(|err| match err {
                err if err.kind() == ErrorKind::NotFound => RepositoryError::NotFound,
                err => RepositoryError::Other(err.into()),
            })?
            .is_file()
        {
            Ok(())
        } else {
            Err(RepositoryError::NotFound)
        }
    }
}

impl Repository for DirectoryRepository {
    fn list_files(&self, package: &str) -> Result<Vec<FileMetadata>, RepositoryError> {
        if !self
            .package_exists(package)
            .map_err(|err| RepositoryError::Other(err.into()))?
        {
            return Err(RepositoryError::NotFound);
        }
        let package_root = self.root.join(package);
        let paths = glob((package_root.to_string_lossy().to_string() + "/**/*").as_str())
            .map_err(|err| RepositoryError::Other(err.into()))?;
        Ok(paths
            .into_iter()
            .filter_map(|result| {
                result.ok().and_then(|path| {
                    let install_path = match path.strip_prefix(&package_root) {
                        Ok(relative) => relative,
                        Err(_err) => {
                            return None;
                        }
                    };
                    FileMetadata::from_path_and_install_path(&path, install_path.to_string_lossy())
                        .ok()
                })
            })
            .collect())
    }
    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError> {
        let target = self.package_root(package).join(path);
        Self::assert_normal_file(&target)?;
        let mut file =
            std::fs::File::open(target).map_err(|err| RepositoryError::Other(err.into()))?;
        let mut buf = vec![];
        file.read_to_end(&mut buf)
            .map_err(|err| RepositoryError::Other(err.into()))?;
        Ok(buf)
    }
    fn get_metadata(&self, package: &str, path: &str) -> Result<FileMetadata, RepositoryError> {
        let target = self.package_root(package).join(path);
        Self::assert_normal_file(&target)?;
        FileMetadata::from_path_and_install_path(target, path)
    }
}

fn io_error_to_repository_error(err: io::Error) -> RepositoryError {
    match err {
        err if err.kind() == ErrorKind::NotFound => RepositoryError::NotFound,
        err => RepositoryError::Other(err.into()),
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        package::{Repository, RepositoryError},
        test_utils::{create_dummy_files, temp_dir::TemporaryDirectory},
    };

    use super::DirectoryRepository;

    struct DirectoryRepositoryTesting {
        #[allow(dead_code)]
        test_dir: TemporaryDirectory,
        repository: DirectoryRepository,
    }

    impl DirectoryRepositoryTesting {
        fn new(paths: &[&str]) -> Self {
            let test_dir = TemporaryDirectory::new_random().unwrap();
            create_dummy_files(test_dir.root(), paths);
            let repository = DirectoryRepository::new(test_dir.root().to_owned());
            Self {
                test_dir,
                repository,
            }
        }
    }

    #[test]
    fn test_list_files() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        let files = testing.repository.list_files("loader").unwrap();
        assert_eq!(2, files.len());
        assert_eq!(
            vec!["bin/loader.lua", "data/config.json"],
            files
                .iter()
                .map(|file| file.install_path.to_string())
                .collect::<Vec<String>>()
        );
        assert!(files.iter().all(|file| file.checksum.len() == 32));
        assert!(matches!(
            testing
                .repository
                .list_files("doomsday_device")
                .unwrap_err(),
            RepositoryError::NotFound
        ));
    }

    #[test]
    fn test_get_file() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert_eq!(
            b"content of loader/bin/loader.lua",
            testing
                .repository
                .get_file("loader", "bin/loader.lua")
                .unwrap()
                .as_slice(),
        );
    }
    #[test]
    fn test_get_file_emtpy_path() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert!(matches!(
            testing.repository.get_file("loader", "").unwrap_err(),
            RepositoryError::NotFound
        ));
    }

    #[test]
    fn test_get_file_non_exists() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert!(matches!(
            testing
                .repository
                .get_file("loader", "bin/loader.java")
                .unwrap_err(),
            RepositoryError::NotFound
        ));
    }

    #[test]
    fn test_get_metadata() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert_eq!(
            "bin/loader.lua",
            testing
                .repository
                .get_metadata("loader", "bin/loader.lua")
                .unwrap()
                .install_path
        );
    }

    #[test]
    fn test_get_metadata_non_exists() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert!(matches!(
            testing
                .repository
                .get_metadata("loader", "bin/loader.java")
                .unwrap_err(),
            RepositoryError::NotFound,
        ),)
    }

    #[test]
    fn test_get_metadata_empty_path() {
        let testing =
            DirectoryRepositoryTesting::new(&["loader/bin/loader.lua", "loader/data/config.json"]);
        assert!(matches!(
            testing.repository.get_metadata("loader", "").unwrap_err(),
            RepositoryError::NotFound,
        ));
    }
}
