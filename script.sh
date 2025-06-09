#!/bin/bash

# Shido Node Upgrade Script for v3.1.0 Upgrade
# This script automates the node upgrade process for the chain proposal at height 17400000

set -e  # Exit on any error

echo "============================================"
echo "    Shido Node Upgrade to v3.1.0 Version"
echo "============================================"
echo "Upgrade Height: 17400000"
echo ""

# Ask user to select Ubuntu version
echo "Please select your Ubuntu version:"
echo "1) Ubuntu 20.04"
echo "2) Ubuntu 22.04/24"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        UBUNTU_VERSION="20.04"
        DOWNLOAD_URL="https://github.com/ShidoGlobal/mainnet-enso-upgrade/releases/download/ubuntu20.04/shidod"
        echo "Selected: Ubuntu 20.04"
        ;;
    2)
        UBUNTU_VERSION="22.04/24"
        DOWNLOAD_URL="https://github.com/ShidoGlobal/mainnet-enso-upgrade/releases/download/ubuntu22.04/shidod"
        echo "Selected: Ubuntu 22.04/24"
        ;;
    *)
        echo "Invalid choice. Please run the script again and select 1 or 2."
        exit 1
        ;;
esac

echo ""
echo "============================================"
echo "Starting Upgrade Process for Ubuntu $UBUNTU_VERSION"
echo "============================================"

# Step 1: Stop the node
echo "Step 1: Stopping shidod service..."
sudo systemctl stop shidod
echo "✓ Service stopped"

# Step 2: Remove the old binary
echo "Step 2: Removing old binary..."
sudo rm -f /usr/local/bin/shidod
echo "✓ Old binary removed"

# Step 3: Download the new binary
echo "Step 3: Downloading new shidod binary for Ubuntu $UBUNTU_VERSION..."
cd $HOME
wget $DOWNLOAD_URL -O shidod
echo "✓ Binary downloaded"

# Step 4: Install and set permissions for new binary
echo "Step 4: Installing new binary..."
sudo mv shidod /usr/local/bin/
sudo chmod +x /usr/local/bin/shidod
echo "✓ New binary installed with proper permissions"

# Step 5: Verify the new version
echo "Step 5: Verifying new version..."
echo "New shidod version:"
/usr/local/bin/shidod version
echo "Expected output: 3.1.0"
echo "✓ Version verified"

# Step 6: Start the node
echo "Step 6: Starting shidod service..."
sudo systemctl restart shidod
echo "✓ Service started"

# Wait a moment for the service to initialize
echo "Waiting 5 seconds for service to initialize..."
sleep 5

# Check service status
echo "Checking service status..."
sudo systemctl status shidod --no-pager -l

echo ""
echo "============================================"
echo "Upgrade process completed successfully!"
echo "============================================"

# Step 7: Offer to monitor logs
echo ""
read -p "Would you like to monitor the logs now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting log monitoring (Press Ctrl+C to exit)..."
    sudo journalctl -u shidod -f --no-hostname -o cat
else
    echo "To monitor logs later, run: sudo journalctl -u shidod -f --no-hostname -o cat"
fi

echo "Upgrade script finished."
