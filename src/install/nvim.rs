use std::process::Command;

use crate::config::Context;
use crate::install::{download, latest_github_version, release_platform, sudo_install, TempDir};
use crate::process::{command_exists, run_status};

pub(crate) fn install(ctx: &Context, packages: &[String]) -> Result<(), String> {
    if has_package(packages, "mise") {
        install_mise()?;
        install_rails()?;
    }
    if has_package(packages, "nvim") {
        install_lazygit(ctx)?;
    }
    Ok(())
}

fn has_package(packages: &[String], package: &str) -> bool {
    packages.iter().any(|candidate| candidate == package)
}

fn install_mise() -> Result<(), String> {
    if command_exists("mise") {
        println!("  mise already installed");
        return Ok(());
    }
    run_status(
        Command::new("sh")
            .arg("-c")
            .arg("curl -fsSL https://mise.run | sh"),
    )
}

fn install_rails() -> Result<(), String> {
    let Some(mise) = mise_command() else {
        return Err("mise was installed, but is not available on PATH".to_string());
    };

    run_status(Command::new(&mise).arg("install"))?;

    if rails_installed(&mise) {
        println!("  rails already installed");
        return Ok(());
    }

    run_status(
        Command::new(&mise)
            .arg("exec")
            .arg("ruby@latest")
            .arg("--")
            .arg("gem")
            .arg("install")
            .arg("rails"),
    )?;
    run_status(Command::new(&mise).arg("reshim"))?;
    println!("  rails installed");
    Ok(())
}

fn mise_command() -> Option<std::path::PathBuf> {
    crate::process::command_path("mise").or_else(|| {
        let candidate = std::path::PathBuf::from(std::env::var_os("HOME")?)
            .join(".local")
            .join("bin")
            .join("mise");
        candidate.is_file().then_some(candidate)
    })
}

fn rails_installed(mise: &std::path::Path) -> bool {
    Command::new(mise)
        .arg("exec")
        .arg("ruby@latest")
        .arg("--")
        .arg("gem")
        .arg("list")
        .arg("-i")
        .arg("rails")
        .status()
        .map(|status| status.success())
        .unwrap_or(false)
}

fn install_lazygit(ctx: &Context) -> Result<(), String> {
    if command_exists("lazygit") {
        println!("  lazygit already installed");
        return Ok(());
    }

    let version = latest_github_version("jesseduffield", "lazygit")?;
    let (os, arch) = release_platform()?;
    let temp_dir = TempDir::new(ctx, "lazygit")?;
    let archive = temp_dir.path.join("lazygit.tar.gz");
    let url = format!(
        "https://github.com/jesseduffield/lazygit/releases/download/v{version}/lazygit_{version}_{os}_{arch}.tar.gz"
    );
    download(&url, &archive)?;
    run_status(
        Command::new("tar")
            .arg("-xzf")
            .arg(&archive)
            .arg("-C")
            .arg(&temp_dir.path)
            .arg("lazygit"),
    )?;
    sudo_install(&temp_dir.path.join("lazygit"), "lazygit")?;
    println!("  lazygit installed");
    Ok(())
}
