mod config;
mod install;
mod process;
mod stow;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "dot", about = "Manage these dotfiles")]
struct Cli {
    #[command(subcommand)]
    command: CliCommand,
}

#[derive(Subcommand)]
enum CliCommand {
    /// Install packages, run package installers, and stow dotfiles.
    Install,
    /// Stow package groups without installing packages.
    Link,
    /// Unstow package groups.
    Uninstall,
}

fn main() {
    if let Err(err) = run() {
        eprintln!("Error: {err}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let ctx = config::Context::new()?;
    match Cli::parse().command {
        CliCommand::Install => install::install(&ctx),
        CliCommand::Link => stow::link(&ctx),
        CliCommand::Uninstall => stow::uninstall(&ctx),
    }
}
