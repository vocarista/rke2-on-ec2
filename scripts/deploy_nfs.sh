#!/bin/bash

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
#     * Install the chart. You must point it to the **internal IP** of your server node.
# ```bash
# Get the internal IP of your server node
SERVER_INTERNAL_IP=$(kubectl get node $(kubectl get nodes -l node-role.kubernetes.io/master=true -o jsonpath='{.items[0].metadata.name}') -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

# Install the chart
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=$SERVER_INTERNAL_IP \
    --set nfs.path=/export/nfs \
    --set storageClass.onDelete=true