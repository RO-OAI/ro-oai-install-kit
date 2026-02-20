#!/bin/bash
set -e

# Idempotent way to enable systemd in /etc/wsl.conf
if [ ! -f /etc/wsl.conf ] || ! grep -q "systemd=true" /etc/wsl.conf; then
    echo "Enabling systemd in /etc/wsl.conf..."
    {
        echo "[boot]"
        echo "systemd=true"
    } | sudo tee /etc/wsl.conf >/dev/null
    
    # Ensure proper permissions
    sudo chown root:root /etc/wsl.conf
    sudo chmod 644 /etc/wsl.conf
else
    echo "Systemd already enabled in /etc/wsl.conf"
fi
