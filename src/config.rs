use std::fs::File;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct ServerConfig {
    pub external_url: Option<String>,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            external_url: Some("http://localhost:3030".to_string()),
        }
    }
}

pub fn load_server_config() -> ServerConfig {
    let file = match File::open("./config.json") {
        Ok(file) => file,
        Err(_err) => {
            return ServerConfig::default();
        }
    };
    serde_json::from_reader(file).unwrap_or(ServerConfig::default())
}

