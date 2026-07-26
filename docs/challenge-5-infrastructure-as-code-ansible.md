The goal of this challenge was to automate the deployment of the application to an existing EC2 instance using Ansible.

Instead of manually installing dependencies, cloning the repository, creating the virtual environment, and configuring systemd, the entire deployment can now be reproduced by executing a single **playbook**.

---
# Infrastructure as Code

Ansible connects to the EC2 instance via SSH and handles the deployment declaratively using a **playbook**, performing the following tasks:

1. Updates the package index and upgrades installed packages.
2. Installs the required system dependencies.
3. Clones or updates the application repository.
4. Creates a Python virtual environment and installs the application dependencies.
5. Generates the systemd service.
6. Reloads systemd and restarts the application service.

This approach makes the deployment reproducible and idempotent, allowing the same playbook to be executed multiple times without producing unintended side effects and only making changes when the server's current state differs from the desired state.

---
# Inventory

The inventory defines the target EC2 instance and the SSH configuration used by Ansible.

```ini
[webservers]
EC2-instance-1 ansible_host=INSTANCE-PUBLIC-IP

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/devops-challenge-key.pem
```

Using an inventory also makes it straightforward to manage multiple servers by adding more hosts to the `webservers` group.

---
# Systemd template

Instead of copying a fixed service file, the playbook uses a **Jinja2** template, allowing values such as the application directory, application user and  greeting message to be configured through Ansible variables while reusing the same template for different environments or servers.

---
# How to run

From the project root:
```bash
# Test connectivity
ansible -i ansible/inventory.ini webservers -m ping

# Deploy
ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml
```

After the playbook finishes, the application is available on the EC2 instance and managed by systemd.

The deployment can be executed again to apply application updates or configuration changes.
