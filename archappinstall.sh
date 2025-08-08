#!/bin/bash

# Update package databases
sudo pacman -Syu --noconfirm

# Install packages from official repositories
while IFS= read -r app; do
    echo "Installing $app..."
    sudo pacman -S --noconfirm --needed "$app"
done < pacman.txt

# Install AUR helper (e.g., yay) if not already installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Install AUR packages (if any in aur.txt are from AUR)
if command -v yay &> /dev/null; then
    echo "Attempting to install remaining packages via yay (AUR)..."
    while IFS= read -r app; do
        yay -S --noconfirm --needed "$app"
    done < aur.txt
fi

echo "Application installation complete."
