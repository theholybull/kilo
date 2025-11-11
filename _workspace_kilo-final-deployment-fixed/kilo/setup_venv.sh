#!/bin/bash
# Kilo Truck Virtual Environment Setup Helper
# Use this BEFORE running any Python scripts

set -e

INSTALL_DIR="/opt/kilo"
VENV_DIR="$INSTALL_DIR/venv"

echo "🐍 Kilo Truck Python Virtual Environment Setup"
echo "============================================="

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: Run with sudo"
   exit 1
fi

# Install required system packages
echo "Installing system dependencies..."
apt update
apt install -y python3-full python3-venv python3-pip

# Create virtual environment
echo "Creating virtual environment at $VENV_DIR..."
mkdir -p $INSTALL_DIR
rm -rf $VENV_DIR  # Remove if exists
python3 -m venv $VENV_DIR

# Activate and upgrade pip
echo "Upgrading pip in virtual environment..."
source $VENV_DIR/bin/activate
pip install --upgrade pip
deactivate

echo "✅ Virtual environment ready!"
echo ""
echo "Usage:"
echo "  source $VENV_DIR/bin/activate    # Activate venv"
echo "  $VENV_DIR/bin/python script.py   # Run script with venv Python"
echo "  $VENV_DIR/bin/pip install package  # Install package in venv"