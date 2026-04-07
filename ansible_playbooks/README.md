# Ansible Playbook

This playbook is what I used to provision my laptop

```
ansible-playbook -v -i inventory.ini playbook.yml --become --ask-become-pass -e "ansible_user_name=$USER"
```