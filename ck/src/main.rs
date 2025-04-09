use serde::Deserialize;
use std::{fs, env, path::Path, path::PathBuf};
use anyhow::{Context, Result};
use clap::Parser;

#[derive(Parser)]
struct Cli {
    /// The pattern to key or folder path
    pattern: String,
    /// If the pattern is key, target is target folder name in config's path with key
    target: Option<String>,
}

#[derive(Deserialize)]
struct Config {
    /// folder's short name
    key: String,
    /// Full path in the machine
    path: String,
}

fn main() -> Result<()> {
    let args = Cli::parse();

    let target = args.target.as_deref().unwrap_or("");

    println!("Arg 1: {}, Arg 2: {}", &args.pattern, &target);

    let current_dir = std::env::current_dir()?;
    let json_path = current_dir.join("../.ck-config.json");
    let content = fs::read_to_string(&json_path)
        .with_context(|| format!("could not read file `{}`", json_path.display()))?;
    let configs: Vec<Config> = serde_json::from_str(&content)?;

    let mut target_path = String::new();;
    for config in configs {
        println!("Key: {}, Path: {}", config.key, config.path);
        if config.key == args.pattern {
            target_path = config.path.clone();
            break;
        }
    }
    if !target.is_empty() {
        target_path.push_str(target);
    } else {
        target_path.push_str(&args.pattern);
    }
    println!("Target path: {}", &target_path);

    let target_dir = Path::new(&target_path);
    env::set_current_dir(&target_dir)?;
    println!("当前目录已切换到: {:?}", env::current_dir()?);

    Ok(())
}
