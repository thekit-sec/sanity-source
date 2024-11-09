#!/bin/bash

# Setup script for macOS Security Toolkit
INSTALL_DIR="/usr/local/security-toolkit"
CONFIG_DIR="/etc/security-toolkit"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Create installation directories
mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

# Copy files to installation directory
cp -r src/* "$INSTALL_DIR/"
cp -r config/* "$CONFIG_DIR/"

# Set permissions
chmod -R 750 "$INSTALL_DIR"
chmod -R 640 "$CONFIG_DIR"/*

# Create symlinks
ln -sf "$INSTALL_DIR/monitoring/metal-compiler-monitor.sh" /usr/local/bin/metal-monitor
ln -sf "$INSTALL_DIR/detection/zz-directory-scanner.sh" /usr/local/bin/zz-scanner

echo "Installation complete. Tools installed in $INSTALL_DIR"
