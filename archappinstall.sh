#!/bin/bash

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Exiting..."
    exit 1
fi

# Log output
exec > >(tee -i install.log)
exec 2>&1

# Update package databases
if ! sudo pacman -Syu --noconfirm; then
    echo "Failed to update package databases. Exiting..."
    exit 1
fi

# Check for pacman.txt
if [[ ! -s pacman.txt ]]; then
    echo "Error: pacman.txt is missing or empty."
    exit 1
fi

# Install packages from official repositories
while IFS= read -r app; do
    echo "Installing $app..."
    sudo pacman -S --noconfirm --needed "$app"
done < pacman.txt

# Install AUR helper (e.g., yay) if not already installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay" || { echo "Failed to navigate to yay directory. Exiting..."; exit 1; }
    if ! makepkg -si --noconfirm; then
        echo "Failed to build and install yay. Exiting..."
        exit 1
    fi
    cd -
    rm -rf "$temp_dir"
fi

# Check for aur.txt
if [[ ! -s aur.txt ]]; then
    echo "Error: aur.txt is missing or empty."
    exit 1
fi

# Install AUR packages (if yay is installed)
if command -v yay &> /dev/null; then
    echo "Attempting to install remaining packages via yay (AUR)..."
    while IFS= read -r app; do
        yay -S --noconfirm --needed "$app"
    done < aur.txt
else
    echo "Error: yay is not available. AUR package installation skipped."
    exit 1
fi

echo "Application installation complete."