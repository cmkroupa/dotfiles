use std::fs;
use std::io::{self, IsTerminal};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use crate::config::{packages_for_groups, Context, GROUPS};
use crate::process::{command_exists, format_output, run_status, run_with_input};

pub(crate) fn link(ctx: &Context) -> Result<(), String> {
    let packages = select_packages("link")?;
    link_packages(ctx, &packages)?;
    println!("Done.");
    Ok(())
}

pub(crate) fn link_packages(ctx: &Context, packages: &[String]) -> Result<(), String> {
    for pkg in packages {
        backup_conflicts(ctx, pkg)?;
        run_status(&mut stow_command(ctx, &[pkg.as_str()]))?;
        println!("  stowed: {pkg}");
    }
    Ok(())
}

pub(crate) fn uninstall(ctx: &Context) -> Result<(), String> {
    let packages = select_packages("unlink")?;
    for pkg in packages {
        let status = stow_command(ctx, &["-D", pkg.as_str()])
            .stderr(Stdio::null())
            .status()
            .map_err(|e| e.to_string())?;
        if status.success() {
            println!("  unlinked: {pkg}");
        } else {
            println!("  (not linked: {pkg})");
        }
        restore_backups(ctx, &pkg)?;
    }
    println!("Done.");
    Ok(())
}

pub(crate) fn stow_command(ctx: &Context, args: &[&str]) -> Command {
    let mut command = Command::new("stow");
    command
        .current_dir(&ctx.root)
        .arg("--target")
        .arg(&ctx.home)
        .arg("--ignore=packages.*\\.txt")
        .arg("--ignore=install\\.sh")
        .args(args);
    command
}

pub(crate) fn select_packages(prompt: &str) -> Result<Vec<String>, String> {
    let groups = if io::stdin().is_terminal() && command_exists("fzf") {
        let input = GROUPS
            .iter()
            .map(|(group, _)| *group)
            .collect::<Vec<_>>()
            .join("\n");
        let output = run_with_input(
            Command::new("fzf")
                .arg("--multi")
                .arg(format!("--prompt={prompt} > "))
                .arg("--header=x/tab: toggle  ctrl-a: all  enter: confirm")
                .arg("--bind")
                .arg("x:toggle,ctrl-a:toggle-all"),
            &input,
        )?;
        let selected = output
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .collect::<Vec<_>>();
        if selected.is_empty() {
            println!("Nothing selected.");
            return Ok(Vec::new());
        }
        selected.into_iter().map(str::to_string).collect::<Vec<_>>()
    } else {
        GROUPS
            .iter()
            .map(|(group, _)| group.to_string())
            .collect::<Vec<_>>()
    };
    Ok(packages_for_groups(&groups))
}

fn backup_conflicts(ctx: &Context, pkg: &str) -> Result<(), String> {
    let output = stow_command(ctx, &["--simulate", pkg])
        .output()
        .map(format_output)
        .map_err(|e| e.to_string())?;

    for target in stow_conflict_targets(&output) {
        let source = ctx.home.join(&target);
        if !source.exists() {
            continue;
        }
        let backup = backup_dir(ctx, pkg).join(&target);
        if let Some(parent) = backup.parent() {
            fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        fs::rename(&source, &backup).map_err(|e| {
            format!(
                "failed to back up {} to {}: {e}",
                source.display(),
                backup.display()
            )
        })?;
        println!(
            "  backed up: ~/{} -> .bak/{pkg}/{}",
            target.display(),
            target.display()
        );
    }

    Ok(())
}

fn stow_conflict_targets(output: &str) -> Vec<PathBuf> {
    output
        .lines()
        .filter_map(|line| {
            if let Some(target) = line
                .split("over existing target ")
                .nth(1)
                .and_then(|value| value.split(" since ").next())
            {
                return Some(PathBuf::from(target.trim()));
            }

            let target = line
                .split("existing target is not owned by stow: ")
                .nth(1)
                .or_else(|| {
                    line.split("existing target is neither a link nor a directory: ")
                        .nth(1)
                })?;
            Some(PathBuf::from(target.trim()))
        })
        .collect()
}

fn restore_backups(ctx: &Context, pkg: &str) -> Result<(), String> {
    let root = backup_dir(ctx, pkg);
    if !root.is_dir() {
        return Ok(());
    }

    for file in files_under(&root)? {
        let rel = file.strip_prefix(&root).map_err(|e| e.to_string())?;
        let dest = ctx.home.join(rel);
        if let Some(parent) = dest.parent() {
            fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        fs::rename(&file, &dest).map_err(|e| {
            format!(
                "failed to restore {} to {}: {e}",
                file.display(),
                dest.display()
            )
        })?;
        println!("  restored: ~/{}", rel.display());
    }

    fs::remove_dir_all(root).map_err(|e| e.to_string())?;
    Ok(())
}

fn files_under(root: &Path) -> Result<Vec<PathBuf>, String> {
    let mut files = Vec::new();
    collect_files(root, &mut files)?;
    Ok(files)
}

fn collect_files(path: &Path, files: &mut Vec<PathBuf>) -> Result<(), String> {
    for entry in fs::read_dir(path).map_err(|e| e.to_string())? {
        let path = entry.map_err(|e| e.to_string())?.path();
        if path.is_dir() {
            collect_files(&path, files)?;
        } else {
            files.push(path);
        }
    }
    Ok(())
}

fn backup_dir(ctx: &Context, pkg: &str) -> PathBuf {
    ctx.root.join(".bak").join(pkg)
}

#[cfg(test)]
mod tests {
    use super::stow_conflict_targets;
    use std::path::PathBuf;

    #[test]
    fn parses_current_stow_conflict_output() {
        let output = "WARNING! stowing zsh would cause conflicts:\n  * cannot stow ../../../dotfiles/zsh/.zshrc over existing target .zshrc since neither a link nor a directory and --adopt not specified\nAll operations aborted.";

        assert_eq!(stow_conflict_targets(output), vec![PathBuf::from(".zshrc")]);
    }

    #[test]
    fn parses_older_stow_conflict_output() {
        let output = "existing target is not owned by stow: .config/nvim/init.lua\nexisting target is neither a link nor a directory: .bashrc";

        assert_eq!(
            stow_conflict_targets(output),
            vec![
                PathBuf::from(".config/nvim/init.lua"),
                PathBuf::from(".bashrc")
            ]
        );
    }
}
