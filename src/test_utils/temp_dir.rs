use std::{
    io,
    path::{Path, PathBuf},
};

use rand::Rng;

#[derive(Debug)]
pub enum TemporaryDirectoryError {
    AlreadyExists,
    IO(io::Error),
}

pub struct TemporaryDirectory {
    root: PathBuf,
}

impl TemporaryDirectory {
    pub fn new(root: PathBuf) -> Result<Self, TemporaryDirectoryError> {
        if root.exists() {
            return Err(TemporaryDirectoryError::AlreadyExists);
        }
        std::fs::create_dir_all(&root).map_err(TemporaryDirectoryError::IO)?;
        Ok(Self { root })
    }

    pub fn new_random() -> Result<Self, TemporaryDirectoryError> {
        Self::new(Self::random_temp_dir())
    }

    pub fn create<P: AsRef<Path>>(&self, relative_path: P) -> PathBuf {
        self.root.join(relative_path)
    }

    pub fn root(&self) -> &Path {
        &self.root
    }

    fn random_temp_dir() -> PathBuf {
        let mut random = rand::thread_rng();
        let suffix = String::from("tempdir_test_")
            + &String::from_iter((0..5).into_iter().map(|_| random.gen_range('a'..='z')));
        PathBuf::new().join("/tmp").join(suffix)
    }
}

impl Drop for TemporaryDirectory {
    fn drop(&mut self) {
        let _result = std::fs::remove_dir_all(&self.root);
    }
}

mod tests {

    use super::TemporaryDirectory;

    #[test]
    fn test_dtor() {
        let dir_path = TemporaryDirectory::random_temp_dir();
        assert!(!dir_path.exists());
        {
            let _dir = TemporaryDirectory::new(dir_path.clone());
            assert!(dir_path.exists());
        }
        assert!(!dir_path.exists());
    }
}
