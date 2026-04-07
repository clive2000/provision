# Provision

Automated machine provisioning using **Ansible**. This repo handles software installation and system configuration — the counterpart to [dotfiles](https://github.com/clive2000/dotfiles) which manages configuration files.

## Supported Platforms

| Platform | Notes |
|----------|-------|
| macOS (Apple Silicon) | Homebrew-based |
| Arch Linux | pacman |
| openSUSE Tumbleweed | zypper |
| Ubuntu | apt |

## Quick Start

### Fresh machine (full bootstrap — provisions + applies dotfiles)

```bash
curl -sL https://raw.githubusercontent.com/clive2000/provision/refs/heads/main/run.sh | bash
```

### Re-provision an existing machine

```bash
cd ~/path/to/provision
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

## Architecture

### Bootstrap Flow (`run.sh`)

```
run.sh
    → installs OS prerequisites (Xcode CLI, Homebrew, git)
    → installs Ansible
    → runs ansible-playbook (provisions machine)
    → installs chezmoi
    → chezmoi init --apply clive2000 (applies dotfiles)
```

### Ansible Roles

| Role | Purpose |
|------|---------|
| `common` | Base packages, Oh My Zsh, Powerlevel10k, vim, zsh config |
| `docker` | Docker installation |
| `github_cli` | GitHub CLI |
| `terminal_emulator` | Ghostty (macOS/Arch/openSUSE), no-op on Ubuntu |
| `terminal_tools` | Modern CLI utilities (atuin, zoxide, eza, etc.) |
| `vscode` | VS Code and Cursor editors |
| `llm_agents` | LLM-related tools (Claude Code, OpenCode, Codex) |

### Brewfiles

Modular Homebrew bundles in `brewfiles/` for manual installation:

- `minimal/` — Core CLI tools
- `coding/` — Development tools
- `cloud/` — Kubernetes & container tools
- `entertainment/` — Media tools

## Related

- **[dotfiles](https://github.com/clive2000/dotfiles)** — Configuration files managed by chezmoi
