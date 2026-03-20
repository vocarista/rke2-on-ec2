# RKE2 on EC2 - Ansible Deployment

Automated deployment of RKE2 (Rancher Kubernetes Engine 2) Kubernetes cluster on AWS EC2 instances. Pushing for my own reference.

## Overview

This Ansible playbook automates the complete setup of a production-ready Kubernetes cluster using RKE2 on EC2, including:
- RKE2 server (control plane) deployment
- RKE2 agent (worker) nodes joining the cluster
- Proper network configuration and security
- Kubectl access setup

## Prerequisites

- Ansible installed on control machine
- AWS EC2 instances launched (Ubuntu 20.04+ recommended)
- SSH access to EC2 instances
- Proper IAM permissions (if using AWS)

## Quick Start

### 1. Configure Inventory

Edit `inventory/hosts.ini` with your EC2 instance details:

```ini
[rke2_servers]
server1 ansible_host=<SERVER_IP> ansible_user=ubuntu

[rke2_agents]
agent1 ansible_host=<AGENT_IP> ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file='~/.ssh/<your-key-file>.pem'
```

### 2. Update SSH Key Path

Ensure your SSH private key path is correct in the inventory file.

### 3. Run the Playbook

```bash
ansible-playbook -i inventory/hosts.ini playbook.yaml
```

## Project Structure

```
├── playbook.yaml              # Main Ansible playbook
├── inventory/
│   └── hosts.ini             # EC2 instance inventory
├── roles/
│   └── rke2_cluster/
│       ├── tasks/
│       │   └── main.yaml    # RKE2 deployment tasks
│       └── templates/
│           ├── server_config.yaml.j2
│           └── agent_config.yaml.j2
├── scripts/
│   ├── deploy_nfs.sh        # NFS storage provisioning
│   └── nfs_infra.sh         # NFS infrastructure setup
└── keys/                     # SSH keys (gitignored)
```

## What Gets Deployed

### RKE2 Server (Control Plane)
- RKE2 server binary installation
- Secure cluster token generation
- TLS certificate configuration
- Kubectl setup and kubeconfig generation
- Systemd service configuration

### RKE2 Agents (Worker Nodes)
- RKE2 agent binary installation
- Automatic cluster joining using secure token
- Network configuration for internal communication
- Systemd service configuration

## Security Features

- **Cluster Token**: Randomly generated 32-character token for node authentication
- **TLS Configuration**: Proper certificate SAN configuration for both private and public IPs
- **SSH Security**: Uses key-based authentication (no passwords)
- **File Permissions**: Secure permissions on kubeconfig and system files

## Post-Deployment

### Access Your Cluster

After deployment, the kubeconfig file will be available at:
- Remote: `/home/ubuntu/.kube/config` on the server
- Local: `rke2.yaml` in the playbook directory

```bash
# Use the local kubeconfig
export KUBECONFIG=./rke2.yaml
kubectl get nodes
```

### Optional: NFS Storage

Deploy NFS storage provisioning:

```bash
# On the server node
./scripts/deploy_nfs.sh
```

## Customization

### Network Configuration

The templates automatically configure:
- **Private IP**: For internal cluster communication
- **Public IP**: Added to TLS SAN for external kubectl access

### Additional Nodes

Add more agents to `inventory/hosts.ini`:

```ini
[rke2_agents]
agent1 ansible_host=<AGENT_IP_1> ansible_user=ubuntu
agent2 ansible_host=<AGENT_IP_2> ansible_user=ubuntu
```

### RKE2 Configuration

Modify the Jinja2 templates in `roles/rke2_cluster/templates/` to customize:
- Cluster token settings
- Network configuration
- TLS settings
- Additional RKE2 parameters

## Troubleshooting

### Common Issues

1. **Node Not Ready**: Check if ports 6443 and 9345 are open in security groups
2. **Agent Can't Join**: Verify server IP and token in agent config
3. **Permission Denied**: Ensure SSH key permissions are correct (600)

### Debug Commands

```bash
# Check RKE2 service status
sudo systemctl status rke2-server
sudo systemctl status rke2-agent

# Check RKE2 logs
sudo journalctl -u rke2-server -f
sudo journalctl -u rke2-agent -f

# Verify cluster status
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

## Security Considerations

- **Never commit** SSH keys or kubeconfig files to version control
- **Use security groups** to restrict access to necessary ports only
- **Regularly update** RKE2 to latest stable version
- **Monitor** cluster access and audit logs

## Ports Required

- **6443**: Kubernetes API server
- **9345**: RKE2 agent registration
- **2379-2380**: etcd (server only)
- **10250**: Kubelet API
- **30000-32767**: NodePort services

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Check the troubleshooting section
- Review RKE2 documentation: https://docs.rke2.io/
- Open an issue in this repository
