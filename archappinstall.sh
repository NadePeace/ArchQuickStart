#!/bin/bash

# Log output
exec > >(tee -i install.log)
exec 2>&1

if ! command -v pacman &> /dev/null; then
    echo -e "\033[0;31mError: Not an Arch system. Exiting...\033[0m"
    exit 1
fi

# Update package databases
if ! sudo pacman -Syu --noconfirm; then
    echo -e "\033[0;31mFailed to update package databases. Exiting...\033[0m"
    exit 1
fi

# Check for pacman.txt
if [[ ! -s pacman.txt ]]; then
    echo -e "\033[0;31mError: pacman.txt is missing or empty.\033[0m"
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
    cd "$temp_dir/yay" || { echo -e "\033[0;31mFailed to navigate to yay directory. Exiting...\033[0m"; exit 1; }
    if ! makepkg -si --noconfirm; then
        echo -e "\033[0;31mFailed to build and install yay. Exiting...\033[0m"
        exit 1
    fi
    cd -
    rm -rf "$temp_dir"
fi

# Check for aur.txt
if [[ ! -s aur.txt ]]; then
    echo -e "\033[0;31mError: aur.txt is missing or empty.\033[0m"
    exit 1
fi

# Install AUR packages (if yay is installed)
if command -v yay &> /dev/null; then
    echo "Attempting to install remaining packages via yay (AUR)..."
    while IFS= read -r app; do
        yay -S --noconfirm --needed "$app"
    done < aur.txt
else
    echo -e "\033[0;31mError: yay is not available. AUR package installation skipped.\033[0m"
    exit 1
fi

echo "Application installation complete."