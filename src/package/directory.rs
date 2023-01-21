use glob::glob;

use super::{File, Repository, RepositoryError};
use md5::Digest;
use std::{
    io::{self, ErrorKind, Read},
    path::PathBuf,
};

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

    fn read_file(&self, package: &str, path: &str) -> io::Result<Vec<u8>> {
        let mut file = std::fs::File::open(self.package_root(package).join(path))?;
        let mut buf = vec![];
        file.read_to_end(&mut buf)?;
        Ok(buf)
    }
}

impl Repository for DirectoryRepository {
    fn list_files(&self, package: &str) -> Result<Vec<File>, RepositoryError> {
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
                    let content = match std::fs::read_to_string(&path) {
                        Ok(content) => content,
                        Err(_err) => {
                            return None;
                        }
                    };
                    let mut hasher = md5::Md5::new();
                    hasher.update(content);
                    Some(File {
                        checksum: format!("{:x}", hasher.finalize()),
                        install_path: install_path.to_string_lossy().to_string(),
                    })
                })
            })
            .collect())
    }
    fn get_file(&self, package: &str, path: &str) -> Result<Vec<u8>, RepositoryError> {
        self.read_file(package, path).map_err(|err| match err {
            err if err.kind() == ErrorKind::NotFound => RepositoryError::NotFound,
            err => RepositoryError::Other(err.into()),
        })
    }
}

#[cfg(test)]
mod tests {
    use std::path::Path;

    use crate::{
        package::{Repository, RepositoryError},
        test_utils::temp_dir::TemporaryDirectory,
    };

    use super::DirectoryRepository;

    #[test]
    fn test_list_files() {
        let test_dir = TemporaryDirectory::new_random().unwrap();
        create_dummy_files(
            test_dir.root(),
            &["loader/bin/loader.lua", "loader/data/config.json"],
        );
        let repository = DirectoryRepository::new(test_dir.root().to_owned());
        let files = repository.list_files("loader").unwrap();
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
            repository.list_files("doomsday_device").unwrap_err(),
            RepositoryError::NotFound
        ));
    }

    #[test]
    fn test_get_file() {
        let test_dir = TemporaryDirectory::new_random().unwrap();
        create_dummy_files(
            test_dir.root(),
            &["loader/bin/loader.lua", "loader/data/config.json"],
        );
        let repository = DirectoryRepository::new(test_dir.root().to_owned());
        assert_eq!(
            b"content of loader/bin/loader.lua",
            repository
                .get_file("loader", "bin/loader.lua")
                .unwrap()
                .as_slice(),
        );
    }

    fn create_dummy_files<P: AsRef<Path>>(root: P, names: &[&str]) {
        for name in names.iter() {
            let target_path = root.as_ref().join(name);
            std::fs::create_dir_all(target_path.parent().unwrap()).unwrap();
            std::fs::write(target_path, format!("content of {}", name)).unwrap();
        }
    }
}
