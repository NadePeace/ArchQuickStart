#!/bin/bash

# Update package databases
sudo pacman -Syu --noconfirm

# Install packages from official repositories
while IFS= read -r app; do
    echo "Installing $app..."
    sudo pacman -S --noconfirm --needed "$app"
done < pacman.txt

# Optional: Install AUR helper (e.g., yay) if not already installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Optional: Install AUR packages (if any in app_list.txt are from AUR)
# This part assumes yay is installed and the app_list.txt might contain AUR packages.
# You might want to separate official packages and AUR packages into different lists.
# For simplicity, if yay is present, it will try to install all listed apps with yay as well.
# This assumes yay can handle official repo packages gracefully.
if command -v yay &> /dev/null; then
    echo "Attempting to install remaining packages via yay (AUR)..."
    while IFS= read -r app; do
        yay -S --noconfirm --needed "$app"
    done < aur.txt
fi

echo "Application installation complete."
