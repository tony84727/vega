use std::{
    io::{self, Write},
    process::{Command, Stdio},
};

use crossbeam::{channel::unbounded, select};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum CompileError {
    #[error("fennel compilation IO issues {0}")]
    IO(io::Error),
    #[error("fennel compilation fail to open stdin of the compiler")]
    FailToOpenStdIn,
    #[error("fennel compilation fail to write stdin")]
    WriteStdIn,
}

pub fn compile(source: Vec<u8>) -> Result<Vec<u8>, CompileError> {
    let mut compile = Command::new("fennel")
        .args(&["-c", "-"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .map_err(CompileError::IO)?;
    let (stdin_sender, stdin_receiver) = unbounded();
    let (output_sender, output_receiver) = unbounded();
    let mut stdin = compile.stdin.take().ok_or(CompileError::FailToOpenStdIn)?;
    let stdin_write =
        std::thread::spawn(move || stdin_sender.send(stdin.write_all(&source)).unwrap());
    let output =
        std::thread::spawn(move || output_sender.send(compile.wait_with_output().unwrap().stdout));
    loop {
        select! {
            recv(stdin_receiver) -> result => match result {
                Ok(result) => result.map_err(CompileError::IO)?,
                Err(_err) => (),
            },
            recv(output_receiver) -> result => {
                stdin_write.join().unwrap();
                output.join().unwrap().unwrap();
                return Ok(result.unwrap());
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::compile;

    #[test]
    fn test_compile() {
        assert_eq!(
            "local message = \"hello world\"\nreturn nil\n".to_string(),
            String::from_utf8(compile(Vec::from("(local message \"hello world\")")).unwrap())
                .unwrap()
        )
    }
}
