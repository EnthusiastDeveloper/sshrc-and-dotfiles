# sshrc-and-dotfiles
My personal sshrc script and dotfiles, matching various environements 

This repository contains my personal dotfiles and sshrc configuration for maintaining a consistent shell environment across different systems.

## Overview

The repository includes:

- `sshrc` - The sshrc script, which is used to replicate the shell environment on remote servers

- `.bashrc` - Main bash configuration with PS1 prompt, history settings, and sourcing of other files
- `.bash_functions` - Various utility bash functions and helper commands
- `.bash_aliases` - Common command aliases and shortcuts
- `.bash_k8s_functions` - Kubernetes-specific functions and aliases
- `.bash_git_functions` - Git workflow helper functions
- `.bash_usingit_api` - Functions for interacting with usingit-edge API
- `.bash_env.public` - Environment variables configurations file (needs to be created by the user)
- `.gitconfig` - Git global configuration file
- `.vimrc` - Vim configuration file

## Key Features

- Customized PS1 prompt with git status integration
- Intelligent command history management
- Color support for ls and other commands
- Tab completion enhancements
- Kubernetes workflow helpers
- Git workflow helpers
- VIM and Git configuration files
- SSH environment replication via sshrc

## Installation

1. Clone this repository
2. Backup your current .bashrc file and any other files you want to keep
3. Copy the files from the `dotfiles` directory to your home directory (or link them)
4. Copy the `sshrc` file to a directory in your path, e.g. `$HOME/.local/bin`

## Usage

### Environment configurations

1. Rename `.bash_env.public` to `.bash_env.private` file in your home directory and add your environment variables
2. Source the `.bashrc` file in your home directory. It will load the `.bash_env.private` file and source the other files in the `dotfiles` directory.

### SSH environment replication

Use the `sshrc` script instead of `ssh` to connect to remote servers, for example:

```bash
sshrc <username>@<hostname>
```
