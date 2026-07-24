use std::process::Command;

use crate::config::Context;
use crate::install::{
    download, find_file_named, latest_github_version, release_platform, rust_release_target,
    sudo_install, TempDir,
};
use crate::process::{command_exists, run_status};

pub(crate) fn install(ctx: &Context, packages: &[String]) -> Result<(), String> {
    if has_package(packages, "shell") {
        install_glow(ctx)?;
    }
    if has_package(packages, "starship") {
        install_starship(ctx)?;
    }
    Ok(())
}

fn has_package(packages: &[String], package: &str) -> bool {
    packages.iter().any(|candidate| candidate == package)
}

fn install_glow(ctx: &Context) -> Result<(), String> {
    if command_exists("glow") {
        println!("  glow already installed");
        return Ok(());
    }

    let version = latest_github_version("charmbracelet", "glow")?;
    let (os, arch) = release_platform()?;
    let temp_dir = TempDir::new(ctx, "glow")?;
    let archive = temp_dir.path.join("glow.tar.gz");
    let url = format!(
        "https://github.com/charmbracelet/glow/releases/download/v{version}/glow_{version}_{os}_{arch}.tar.gz"
    );
    download(&url, &archive)?;
    run_status(
        Command::new("tar")
            .arg("-xzf")
            .arg(&archive)
            .arg("-C")
            .arg(&temp_dir.path),
    )?;
    let binary = find_file_named(&temp_dir.path, "glow")
        .ok_or_else(|| "glow binary not found in archive".to_string())?;
    sudo_install(&binary, "glow")?;
    println!("  glow installed");
    Ok(())
}

fn install_starship(ctx: &Context) -> Result<(), String> {
    if command_exists("starship") {
        println!("  starship already installed");
        return Ok(());
    }

    let version = latest_github_version("starship", "starship")?;
    let target = rust_release_target()?;
    let temp_dir = TempDir::new(ctx, "starship")?;
    let archive = temp_dir.path.join("starship.tar.gz");
    let url = format!(
        "https://github.com/starship/starship/releases/download/v{version}/starship-{target}.tar.gz"
    );
    download(&url, &archive)?;
    run_status(
        Command::new("tar")
            .arg("-xzf")
            .arg(&archive)
            .arg("-C")
            .arg(&temp_dir.path),
    )?;
    sudo_install(&temp_dir.path.join("starship"), "starship")?;
    println!("  starship installed");
    Ok(())
}
