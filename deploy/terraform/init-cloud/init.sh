#!/usr/bin/env bash
set -eux

# Input from cloud-init
GITHUB_REPO=$1
export PROJECT_CODE=$2 # Used in chef persistent volume mounting 

# Deployment initialisation
ssh-keyscan github.com 2> /dev/null >> /etc/ssh/ssh_known_hosts
git config --system advice.detachedHead false
mkdir -p /var/deployment

cd /var/deployment
git rev-parse --is-inside-work-tree || git clone "$GITHUB_REPO" .

cd deploy/chef
HOME=/root ./init
