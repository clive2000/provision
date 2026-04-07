#!/bin/bash

set -e

GITHUB_USERNAME="clive2000"

detect_os() {
    local os=$(uname -s)

    case $os in
        Darwin)
            OS="darwin"
            ;;
        Linux)
            OS="linux"
            ;;
        *)
            echo "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

install_xcode_cli_tools() {
    set +e
    xcode-select -p &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
        softwareupdate -i "$PROD" --verbose;
    else
        echo "Command Line Tools for Xcode have been installed."
    fi
    set -e
}

install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew"
        sudo echo 'Getting sudo session...'
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.zprofile
        eval $(/opt/homebrew/bin/brew shellenv)
    fi
}

install_git_linux() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ $ID == "ubuntu" ]]; then
            echo "Ubuntu detected, installing git..."
            sudo apt-get update
            sudo apt-get install -y git curl
        elif [[ $ID == "opensuse"* ]]; then
            echo "openSUSE detected, installing git..."
            sudo zypper refresh
            sudo zypper install -y git curl
        elif [[ $ID == "arch" ]]; then
            echo "Arch Linux detected, installing git..."
            sudo pacman -Syu --noconfirm git curl
        else
            echo "Unsupported Linux distribution: $ID"
            echo "Supported distributions: ubuntu, opensuse (Tumbleweed), arch"
            exit 1
        fi
    else
        echo "Could not detect Linux distribution (missing /etc/os-release)"
        exit 1
    fi
}

install_chezmoi() {
    if ! command -v chezmoi >/dev/null 2>&1; then
        echo "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "chezmoi is already installed."
    fi
}

install_ansible_macos() {
    echo "Setting up macOS environment..."

    # Ensure Homebrew is available
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

    if ! command -v ansible-playbook &> /dev/null; then
        echo "Installing Ansible..."
        brew install ansible
    fi
}

install_ansible_linux() {
    echo "Setting up Linux environment..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID=$ID
    else
        echo "Could not detect Linux distribution"
        exit 1
    fi

    case $DISTRO_ID in
        ubuntu|debian)
            echo "Debian/Ubuntu detected, installing dependencies..."
            sudo apt-get update
            sudo apt-get install -y ansible git gpg
            ;;
        opensuse*)
            echo "openSUSE detected, installing dependencies..."
            sudo zypper install -y ansible git gpg
            ;;
        arch)
            echo "Arch Linux detected, installing dependencies..."
            sudo pacman -Syu --noconfirm ansible git gnupg
            ;;
        *)
            echo "Unsupported Linux distribution: $DISTRO_ID"
            exit 1
            ;;
    esac
}

run_ansible() {
    echo "Installing Ansible collections..."
    ansible-galaxy collection install community.general --force

    # Determine the playbook directory
    # If running from a cloned repo, use the local path
    # Otherwise, fall back to ~/.config/provision/ansible_playbooks
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/ansible_playbooks/playbook.yml" ]; then
        PLAYBOOK_DIR="$SCRIPT_DIR/ansible_playbooks"
    else
        PLAYBOOK_DIR="$HOME/.config/provision/ansible_playbooks"
    fi

    echo "Running Ansible playbook from $PLAYBOOK_DIR..."
    pushd "$PLAYBOOK_DIR"
    ansible-playbook -v -i inventory.ini playbook.yml --become --ask-become-pass -e "ansible_user_name=$USER"
    popd
}

apply_dotfiles() {
    echo "Applying dotfiles with chezmoi..."
    if [ -d "$HOME/.local/share/chezmoi" ]; then
        "$HOME/.local/bin/chezmoi" apply
    else
        "$HOME/.local/bin/chezmoi" init --apply "$GITHUB_USERNAME"
    fi
}

# =============================================================================
# Main
# =============================================================================

detect_os

echo "=============================================="
echo "  Provisioning & Dotfiles Bootstrap"
echo "=============================================="

# Step 1: Install OS-level prerequisites
if [ "$OS" == "darwin" ]; then
    echo ""
    echo "[1/4] Installing macOS prerequisites..."
    install_xcode_cli_tools
    install_homebrew
fi

if [ "$OS" == "linux" ]; then
    echo ""
    echo "[1/4] Installing Linux prerequisites..."
    install_git_linux
fi

# Step 2: Install Ansible and run provisioning
echo ""
echo "[2/4] Installing Ansible..."
if [ "$OS" == "darwin" ]; then
    install_ansible_macos
else
    install_ansible_linux
fi

echo ""
echo "[3/4] Running provisioning playbook..."
run_ansible

# Step 3: Install chezmoi and apply dotfiles
echo ""
echo "[4/4] Installing and applying dotfiles..."
install_chezmoi
apply_dotfiles

echo ""
echo "=============================================="
echo "  Setup complete!"
echo ""
echo "  Provisioning and dotfiles have been applied."
echo "  Please restart your terminal."
echo "=============================================="
