use std::path::Path;

pub mod temp_dir;

pub fn create_dummy_files<P: AsRef<Path>>(root: P, names: &[&str]) {
    for name in names.iter() {
        let target_path = root.as_ref().join(name);
        std::fs::create_dir_all(target_path.parent().unwrap()).unwrap();
        std::fs::write(target_path, format!("content of {}", name)).unwrap();
    }
}
