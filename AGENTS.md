# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

## Mandatory Rules

> ⚠️ **RULE: All changes MUST be made in a feature branch.**
> Never commit directly to `main`.
> Always create a dedicated feature branch before making any edits, e.g.:
> ```bash
> git checkout -b feature/<short-description>
> ```
> Open a pull request to merge the feature branch back into the trunk branch when the work is complete.

## Overview

This is a machine provisioning repository using **Ansible** for automated software installation and system configuration. It is the companion to the [dotfiles](https://github.com/clive2000/dotfiles) repo (which manages configuration files via chezmoi).

## Supported Platforms

| Platform | Notes |
|----------|-------|
| macOS (Apple Silicon) | Homebrew-based |
| Arch Linux | pacman |
| openSUSE Tumbleweed | zypper |
| Ubuntu | apt |

## Key Commands

### Full bootstrap (fresh machine)
```bash
curl -sL https://raw.githubusercontent.com/clive2000/provision/refs/heads/main/run.sh | bash
```

### Re-provision an existing machine
```bash
./provision.sh
```

### Run Ansible manually
```bash
cd ansible_playbooks
ansible-playbook -v -i inventory.ini playbook.yml --become --ask-become-pass -e "ansible_user_name=$USER"
```

### Validate Ansible syntax
```bash
ansible-playbook --syntax-check ansible_playbooks/playbook.yml
```

## Repository Structure

```
provision/
├── run.sh                   # Full bootstrap (prereqs + Ansible + chezmoi)
├── provision.sh             # Re-run Ansible provisioning only
├── ansible_playbooks/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── common/          # Base packages, Oh My Zsh, Powerlevel10k, vim, zsh
│       ├── docker/          # Docker installation
│       ├── github_cli/      # GitHub CLI
│       ├── terminal_emulator/  # Ghostty
│       ├── terminal_tools/  # Modern CLI utilities
│       ├── vscode/          # VS Code / Cursor
│       └── llm_agents/      # LLM tools (Claude Code, OpenCode, Codex)
├── brewfiles/
│   ├── minimal/
│   ├── coding/
│   ├── cloud/
│   └── entertainment/
├── AGENTS.md                # This file
└── README.md
```

## Architecture

### Bootstrap Flow
```
run.sh
    → installs OS prerequisites (Xcode CLI, Homebrew, git)
    → installs Ansible
    → runs ansible-playbook (provisions machine)
    → installs chezmoi
    → chezmoi init --apply clive2000 (applies dotfiles from separate repo)
```

### Relationship with dotfiles repo
- **This repo (provision)**: Installs software — runs infrequently (new machine, new tools)
- **dotfiles repo**: Manages config files via chezmoi — updated frequently
- `run.sh` orchestrates both for fresh machines
- Each can be run independently after initial setup
