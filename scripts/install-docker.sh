#!/bin/bash
set -e
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable' |
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start + enable Docker (checking for systemd first)
if pidof systemd >/dev/null; then
    echo "Starting Docker via systemd..."
    sudo systemctl enable --now docker
    sudo systemctl status docker --no-pager
else
    echo "Warning: systemd is not active (PID 1 is $(ps -p 1 -o comm=)). Fallback to service command."
    echo "Diagnostics: /etc/wsl.conf content:"
    cat /etc/wsl.conf || echo "/etc/wsl.conf not found"
    # Ensure /etc/init.d/docker is present and daemon is not blocked
    sudo service docker start || {
        echo "Service start failed. Attempting to start daemon manually for diagnostics..."
        sudo dockerd &
        sleep 5
    }
    sudo service docker status || true
fi

# Allow current user to run docker without sudo (takes effect on a new login/session)
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"

# Refresh group membership for the current script execution
if [ "$(id -gn)" != "docker" ]; then
    echo "Refreshing group membership..."
    # This might not work in all shell environments non-interactively, 
    # but we can try to use 'newgrp' or just continue with sudo for the rest of this script
    # For now, we'll just ensure the rest of the script uses sudo if needed or inform user
    echo "Note: Group membership updated. You may need to logout and login for 'docker' command to work without sudo."
fi

# Basic verification (daemon + socket)
if pidof systemd >/dev/null; then
    sudo systemctl is-active docker
else
    sudo service docker status
fi
if [ ! -S /var/run/docker.sock ]; then
    echo "ERROR: /var/run/docker.sock not found. The Docker daemon is not running properly."
    ls -la /var/run/docker.sock || echo "Socket definitely missing"
    exit 1
fi

echo "Verifying Docker connection with sudo..."
sudo docker version
