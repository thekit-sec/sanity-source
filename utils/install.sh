#!/bin/bash

# Deployment script for macOS Security Toolkit
TOOLKIT_DIR="/usr/local/security-toolkit"
LOG_DIR="/var/log/security-toolkit"
CONFIG_DIR="/etc/security-toolkit"

setup_directories() {
    mkdir -p "$TOOLKIT_DIR" "$LOG_DIR" "$CONFIG_DIR"
    chmod 750 "$TOOLKIT_DIR" "$LOG_DIR"
    chmod 640 "$CONFIG_DIR"
}

install_dependencies() {
    if ! command -v sqlite3 &> /dev/null; then
        echo "Installing sqlite3..."
        brew install sqlite
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "Installing Python3..."
        brew install python
    fi
}

deploy_tools() {
    cp -r ../src/* "$TOOLKIT_DIR/"
    cp -r ../config/* "$CONFIG_DIR/"
    
    # Set up logging
    touch "$LOG_DIR/metal-monitor.log"
    touch "$LOG_DIR/alerts.log"
    
    # Create symlinks
    ln -sf "$TOOLKIT_DIR/monitoring/metal-compiler-monitor.sh" /usr/local/bin/metal-monitor
    ln -sf "$TOOLKIT_DIR/detection/zz-directory-scanner.sh" /usr/local/bin/zz-scanner
}

setup_launchd() {
    cat > /Library/LaunchDaemons/com.security-toolkit.metal-monitor.plist << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.security-toolkit.metal-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/metal-monitor</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/security-toolkit/metal-monitor.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/security-toolkit/metal-monitor.error.log</string>
</dict>
</plist>
EOL
}

main() {
    echo "Installing macOS Security Toolkit..."
    setup_directories
    install_dependencies
    deploy_tools
    setup_launchd
    echo "Installation complete. Use 'metal-monitor' or 'zz-scanner' to run tools."
}

main "$@"
