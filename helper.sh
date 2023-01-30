#!/bin/bash
set -e
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check to see if this has run before
if [ -f inventory.ini ]; then
    read -p "Found inventory.ini ~ Delete this file & generate new inventory.ini via Vagrant? " -n 1 -r
    # echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf inventory.ini
        echo
        echo "Deleted Ansible Inventory!"
        echo
        echo "Creating New Dynamic Inventory via Vagrant!"
        touch inventory.ini

        vagrant_boxes=$(vagrant global-status | awk '/running/{print $1}' | xargs)
        for host_guid in  $vagrant_boxes; do
            box_host=$(vagrant ssh-config $host_guid| grep Host | xargs | cut -d " " -f2)
            box_hostname=$(vagrant ssh-config $host_guid| grep HostName | xargs | cut -d " " -f2)
            box_user=$(vagrant ssh-config $host_guid | grep User | xargs | cut -d " " -f2)
            box_port=$(vagrant ssh-config $host_guid| grep Port | xargs | cut -d " " -f2)
            box_identityfile=$(vagrant ssh-config $host_guid | grep IdentityFile | xargs | cut -d " " -f2)
            
            # 127.0.0.1  ansible_port=2222  ansible_connection=ssh        ansible_user=vagrant  ansible_ssh_private_key_file=/Users/mark.west/github/inside/petshop/examples/aio/.vagrant/machines/vault-0/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'
            echo "adding: $box_host  ansible_host=$box_hostname     ansible_port=$box_port     ansible_user=$box_user        ansible_ssh_private_key_file=$box_identityfile      ansible_ssh_common_args='-o StrictHostKeyChecking=no' \n to inventory.ini... \n\n "
            echo "$box_host  ansible_host=$box_hostname     ansible_port=$box_port     ansible_user=$box_user        ansible_ssh_private_key_file=$box_identityfile      ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory.ini
        
        done
        cat inventory.ini
    else
        echo "Using Existing Inventory"
    fi
fi



ansible-playbook main.yml --check


echo "Done & Done."

