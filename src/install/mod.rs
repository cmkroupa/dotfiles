mod gui;
mod nvim;
mod terminal;

use std::collections::BTreeSet;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::config::{runtime_conflicts, Context};
use crate::process::{command_exists, command_output, command_status, run_status};
use crate::stow;

pub(crate) fn install(ctx: &Context) -> Result<(), String> {
    println!("OS: {}  |  PM: {}", ctx.os, ctx.pm);
    require_stow(&ctx.pm)?;
    let packages = stow::select_packages("install")?;
    if packages.is_empty() {
        return Ok(());
    }
    if packages.iter().any(|package| package == "mise") {
        abort_on_runtime_conflicts(ctx)?;
    }
    install_packages(ctx, &packages)?;
    stow::link_packages(ctx, &packages)?;
    terminal::install(ctx, &packages)?;
    nvim::install(ctx, &packages)?;
    gui::install(ctx, &packages)?;
    let rc = match env::var("SHELL").unwrap_or_default().as_str() {
        shell if shell.ends_with("/zsh") => "~/.zshrc",
        shell if shell.ends_with("/bash") => "~/.bashrc",
        _ => "your shell's rc file",
    };
    println!("Done. Run: source {rc}");
    Ok(())
}

fn abort_on_runtime_conflicts(ctx: &Context) -> Result<(), String> {
    let conflicts = runtime_conflicts(ctx);
    if conflicts.is_empty() {
        return Ok(());
    }
    println!(
        "Error: conflicting runtime managers detected: {}",
        conflicts
            .iter()
            .map(|(name, _)| name.as_str())
            .collect::<Vec<_>>()
            .join(" ")
    );
    for (name, detail) in conflicts {
        println!("  - {name}: {detail}");
    }
    println!("  Remove their shell startup hooks, then reload your shell before installing.");
    println!("  This setup expects mise to own runtime activation so PATH/shims do not fight.");
    Err("runtime-manager conflicts found".to_string())
}

fn require_stow(pm: &str) -> Result<(), String> {
    if command_exists("stow") {
        return Ok(());
    }
    let cmd = match pm {
        "apt" => "sudo apt install stow",
        "brew" => "brew install stow",
        "pacman" => "sudo pacman -S stow",
        "dnf" => "sudo dnf install stow",
        _ => "install stow via your package manager",
    };
    Err(format!("stow required: {cmd}"))
}

pub(crate) fn package_manifest_entries(ctx: &Context, stow_packages: &[String]) -> Vec<String> {
    let mut seen = BTreeSet::new();
    let mut packages = Vec::new();
    for pkg in stow_packages {
        let pm_file = ctx.root.join(pkg).join(format!("packages.{}.txt", ctx.pm));
        let generic_file = ctx.root.join(pkg).join("packages.txt");
        let file = if pm_file.is_file() {
            pm_file
        } else {
            generic_file
        };
        if !file.is_file() {
            continue;
        }
        if let Ok(content) = fs::read_to_string(file) {
            for line in content.lines().map(str::trim) {
                if line.is_empty() || line.starts_with('#') {
                    continue;
                }
                if seen.insert(line.to_string()) {
                    packages.push(line.to_string());
                }
            }
        }
    }
    packages
}

fn install_packages(ctx: &Context, stow_packages: &[String]) -> Result<(), String> {
    let packages = package_manifest_entries(ctx, stow_packages);
    if packages.is_empty() {
        return Ok(());
    }
    match ctx.pm.as_str() {
        "brew" => {
            let missing = packages
                .iter()
                .filter(|pkg| !command_status("brew", &["list", "--formula", pkg]))
                .cloned()
                .collect::<Vec<_>>();
            if !missing.is_empty() {
                let mut command = Command::new("brew");
                command
                    .arg("install")
                    .args(&missing)
                    .env("HOMEBREW_NO_INSTALL_UPGRADE", "1")
                    .env("HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK", "1");
                run_status(&mut command)?;
            }
        }
        "apt" => run_status(
            Command::new("sudo")
                .arg("apt")
                .arg("install")
                .arg("-y")
                .args(&packages),
        )?,
        "pacman" => run_status(
            Command::new("sudo")
                .arg("pacman")
                .arg("-S")
                .arg("--noconfirm")
                .args(&packages),
        )?,
        "dnf" => run_status(
            Command::new("sudo")
                .arg("dnf")
                .arg("install")
                .arg("-y")
                .args(&packages),
        )?,
        _ => println!(
            "No package manager - install manually: {}",
            packages.join(" ")
        ),
    }
    Ok(())
}

pub(super) fn latest_github_version(owner: &str, repo: &str) -> Result<String, String> {
    let mut command = Command::new("curl");
    command.arg("-fsSL").arg(format!(
        "https://api.github.com/repos/{owner}/{repo}/releases/latest"
    ));
    let output = command_output(command)?;
    output
        .lines()
        .find_map(|line| line.trim().strip_prefix("\"tag_name\":"))
        .and_then(|value| value.split('"').nth(1))
        .and_then(|tag| tag.strip_prefix('v'))
        .map(str::to_string)
        .ok_or_else(|| format!("could not determine {repo} version"))
}

pub(super) fn release_platform() -> Result<(&'static str, &'static str), String> {
    let os = match std::env::consts::OS {
        "linux" => "Linux",
        "macos" => "Darwin",
        other => return Err(format!("unsupported OS: {other}")),
    };
    let arch = match std::env::consts::ARCH {
        "x86_64" => "x86_64",
        "aarch64" => "arm64",
        other => return Err(format!("unsupported arch: {other}")),
    };
    Ok((os, arch))
}

pub(super) fn rust_release_target() -> Result<&'static str, String> {
    match (std::env::consts::OS, std::env::consts::ARCH) {
        ("linux", "x86_64") => Ok("x86_64-unknown-linux-gnu"),
        ("linux", "aarch64") => Ok("aarch64-unknown-linux-gnu"),
        ("macos", "x86_64") => Ok("x86_64-apple-darwin"),
        ("macos", "aarch64") => Ok("aarch64-apple-darwin"),
        (os, arch) => Err(format!("unsupported platform: {os}/{arch}")),
    }
}

pub(super) fn download(url: &str, dest: &Path) -> Result<(), String> {
    run_status(Command::new("curl").arg("-fLo").arg(dest).arg(url))
}

pub(super) fn sudo_install(source: &Path, name: &str) -> Result<(), String> {
    run_status(
        Command::new("sudo")
            .arg("install")
            .arg(source)
            .arg(format!("/usr/local/bin/{name}")),
    )
}

pub(super) fn find_file_named(root: &Path, name: &str) -> Option<PathBuf> {
    for entry in fs::read_dir(root).ok()? {
        let path = entry.ok()?.path();
        if path.is_dir() {
            if let Some(found) = find_file_named(&path, name) {
                return Some(found);
            }
        } else if path.file_name().is_some_and(|file_name| file_name == name) {
            return Some(path);
        }
    }
    None
}

pub(super) struct TempDir {
    pub(super) path: PathBuf,
}

impl TempDir {
    pub(super) fn new(_ctx: &Context, prefix: &str) -> Result<Self, String> {
        let root = env::temp_dir().join("dot-install");
        fs::create_dir_all(&root).map_err(|e| e.to_string())?;
        for attempt in 0..100 {
            let path = root.join(format!("{prefix}-{}-{attempt}", std::process::id()));
            if !path.exists() {
                fs::create_dir(&path).map_err(|e| e.to_string())?;
                return Ok(Self { path });
            }
        }
        Err(format!("could not create temporary directory for {prefix}"))
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.path);
    }
}
