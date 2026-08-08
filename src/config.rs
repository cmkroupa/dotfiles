use std::env;
use std::fs;
use std::path::{Path, PathBuf};

use crate::process::{command_exists, command_path, run_stdout};

pub(crate) const GROUPS: &[(&str, &[&str])] = &[
    ("terminal", &["shell", "zsh", "starship"]),
    ("nvim", &["mise", "nvim"]),
    ("gui", &["ghostty"]),
];


const RUNTIME_MANAGERS: &[RuntimeManager] = &[
    RuntimeManager {
        name: "pyenv",
        env_vars: &[],
        dirs: &[".pyenv"],
    },
    RuntimeManager {
        name: "conda",
        env_vars: &["CONDA_PREFIX", "CONDA_EXE"],
        dirs: &["miniconda3", "anaconda3"],
    },
    RuntimeManager {
        name: "nvm",
        env_vars: &["NVM_DIR"],
        dirs: &[".nvm"],
    },
    RuntimeManager {
        name: "asdf",
        env_vars: &[],
        dirs: &[".asdf"],
    },
    RuntimeManager {
        name: "rbenv",
        env_vars: &[],
        dirs: &[".rbenv"],
    },
    RuntimeManager {
        name: "rvm",
        env_vars: &[],
        dirs: &[".rvm"],
    },
];

#[derive(Clone, Copy)]
struct RuntimeManager {
    name: &'static str,
    env_vars: &'static [&'static str],
    dirs: &'static [&'static str],
}

pub(crate) struct Context {
    pub(crate) root: PathBuf,
    pub(crate) home: PathBuf,
    pub(crate) os: String,
    pub(crate) pm: String,
}

impl Context {
    pub(crate) fn new() -> Result<Self, String> {
        let home = env::var_os("HOME")
            .map(PathBuf::from)
            .ok_or_else(|| "HOME is not set".to_string())?;
        let root = find_dotfiles_root(&home)?;
        Ok(Self {
            root,
            home,
            os: detect_os(),
            pm: detect_pm(),
        })
    }
}

pub(crate) fn packages_for_groups(groups: &[String]) -> Vec<String> {
    let mut packages = Vec::new();
    for group in groups {
        if let Some((_, group_packages)) = GROUPS.iter().find(|(name, _)| name == group) {
            packages.extend(group_packages.iter().map(|pkg| (*pkg).to_string()));
        }
    }
    packages
}

pub(crate) fn runtime_conflicts(ctx: &Context) -> Vec<(String, String)> {
    let mut conflicts = Vec::new();
    for manager in RUNTIME_MANAGERS {
        if let Some(path) = command_path(manager.name) {
            conflicts.push((
                manager.name.to_string(),
                format!("found on PATH at {}", path.display()),
            ));
            continue;
        }

        let mut found_env_conflict = false;
        for env_var in manager.env_vars {
            if let Ok(value) = env::var(env_var) {
                if !value.is_empty() {
                    conflicts.push((
                        manager.name.to_string(),
                        format!("{env_var} is set to {value}"),
                    ));
                    found_env_conflict = true;
                    break;
                }
            }
        }
        if found_env_conflict {
            continue;
        }

        for dir in manager.dirs {
            let path = ctx.home.join(dir);
            if path.is_dir() {
                conflicts.push((
                    manager.name.to_string(),
                    format!("directory exists at {}", path.display()),
                ));
                break;
            }
        }
    }
    conflicts
}

fn find_dotfiles_root(home: &Path) -> Result<PathBuf, String> {
    let mut candidates = Vec::new();
    if let Some(root) = env::var_os("DOTFILES_DIR").map(PathBuf::from) {
        candidates.push(root);
    }
    if let Ok(current_dir) = env::current_dir() {
        for path in current_dir.ancestors() {
            candidates.push(path.to_path_buf());
        }
    }
    candidates.push(home.join("dotfiles"));

    for root in candidates {
        if validate_root(&root).is_ok() {
            return Ok(root);
        }
    }

    Err(format!(
        "could not find the dotfiles repo; run from the checkout or set DOTFILES_DIR"
    ))
}

fn validate_root(root: &Path) -> Result<(), String> {
    let manifest = root.join("Cargo.toml");
    let Ok(content) = fs::read_to_string(&manifest) else {
        return Err(format!(
            "{} does not look like the dotfiles repo: missing Cargo.toml",
            root.display()
        ));
    };
    if !content.lines().any(|line| line.trim() == "name = \"dot\"")
        || !root.join("src/main.rs").is_file()
    {
        return Err(format!(
            "{} does not look like the dotfiles repo",
            root.display()
        ));
    }
    Ok(())
}

fn detect_os() -> String {
    if run_stdout("uname", &[]).trim() == "Darwin" {
        "macOS".to_string()
    } else {
        fs::read_to_string("/etc/os-release")
            .ok()
            .and_then(|s| {
                s.lines()
                    .find_map(|line| line.strip_prefix("NAME="))
                    .map(|v| v.trim_matches('"').to_string())
            })
            .unwrap_or_else(|| "unknown".to_string())
    }
}

fn detect_pm() -> String {
    for pm in ["brew", "apt", "dnf"] {
        if command_exists(pm) {
            return pm.to_string();
        }
    }
    "none".to_string()
}
