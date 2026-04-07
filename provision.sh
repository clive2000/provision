#!/bin/bash

# Re-run the Ansible provisioning playbook on an already-set-up machine.
# Usage: ./provision.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$SCRIPT_DIR/ansible_playbooks"

if [ ! -f "$PLAYBOOK_DIR/playbook.yml" ]; then
    echo "Error: playbook.yml not found in $PLAYBOOK_DIR"
    echo "Make sure you're running this from the provision repo root."
    exit 1
fi

echo "Installing Ansible collections..."
ansible-galaxy collection install community.general --force

echo "Running Ansible playbook..."
pushd "$PLAYBOOK_DIR"
ansible-playbook -v -i inventory.ini playbook.yml --become --ask-become-pass -e "ansible_user_name=$USER"
popd

echo ""
echo "Provisioning complete!"
