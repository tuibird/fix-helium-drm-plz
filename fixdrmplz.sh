#!/bin/bash
set -e  # Exit on error

# True color (24-bit RGB) codes - forces actual colors regardless of terminal theme
GREEN='\033[38;2;40;200;64m'
YELLOW='\033[38;2;255;200;0m'
RED='\033[38;2;255;60;60m'
BLUE='\033[38;2;80;160;255m'
CYAN='\033[38;2;0;200;200m'
MAGENTA='\033[38;2;200;100;255m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[•]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_download() {
    echo -e "${CYAN}[↓]${NC} $1"
}

print_package() {
    echo -e "${MAGENTA}[→]${NC} $1"
}

# Error handler
cleanup_on_error() {
    print_error "An error occurred. Cleaning up..."
    cd /
    rm -rf /tmp/chromium_widevine
    exit 1
}

trap cleanup_on_error ERR

# Start
echo "╔════════════════════════════════════════╗"
echo -e "║   ${CYAN}Widevine CDM Installer for Helium${NC}    ║"
echo -e "║                ${MAGENTA}By Tui${NC}                  ║"
echo "╚════════════════════════════════════════╝"
echo

# Check for sudo permissions
print_info "Checking sudo permissions..."
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo access to install to /usr/share/helium/"
    echo
    echo -n "Gimmie dat sudo access >:3   "
    if ! sudo true; then
        echo
        print_error "I can't fix shit without sudo permissions hun"
        print_warning "Run this script as a user with sudo access or fuck off"
        exit 1
    fi
    echo
fi
print_success "Sudo access confirmed"
echo

# Fetch latest Chrome version
print_download "Fetching latest stable Chrome version..."
_chrome_ver=$(curl -sL https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages | grep -A 5 "Package: google-chrome-stable" | grep "Version:" | head -1 | awk '{print $2}' | cut -d'-' -f1)

if [ -z "$_chrome_ver" ]; then
    print_error "Failed to fetch Chrome version"
    exit 1
fi

print_success "Found Chrome version: $_chrome_ver"
echo

# Set target directory
_target_dir=/usr/share/helium/WidevineCdm
print_info "Target directory: $_target_dir"
echo

# Create temporary directory
print_info "Creating temporary workspace..."
mkdir -p /tmp/chromium_widevine
cd /tmp/chromium_widevine
print_success "Working directory: /tmp/chromium_widevine"
echo

# Download Chrome package
_deb_file="google-chrome-stable_${_chrome_ver}-1_amd64.deb"
print_download "Downloading Chrome package (this may take a while)..."
echo

if wget -c "https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/$_deb_file"; then
    echo
    print_success "Download complete: $_deb_file"
else
    echo
    print_error "Download failed - check your internet connection"
    exit 1
fi
echo

# Extract package
print_package "Extracting package..."
rm -rf unpack_deb
mkdir unpack_deb

if ! ar x "$_deb_file" 2>/dev/null; then
    print_error "Failed to extract .deb archive (is 'ar' installed?)"
    exit 1
fi

if ! tar -xf data.tar.xz -C unpack_deb 2>/dev/null; then
    print_error "Failed to extract data archive"
    exit 1
fi

rm -f control.tar.* data.tar.* debian-binary
print_success "Extraction complete"
echo

# Verify WidevineCdm was extracted
if [ ! -d "unpack_deb/opt/google/chrome/WidevineCdm" ]; then
    print_error "WidevineCdm directory not found in package"
    exit 1
fi

_widevine_version=$(cat unpack_deb/opt/google/chrome/WidevineCdm/manifest.json | grep '"version"' | head -1 | awk -F'"' '{print $4}')
print_success "Found Widevine CDM version: $_widevine_version"
echo

# Install to Helium directory
print_info "Installing Widevine to Helium..."
sudo mkdir -p "$(dirname "$_target_dir")"
sudo rm -rf "$_target_dir"
sudo mv unpack_deb/opt/google/chrome/WidevineCdm "$_target_dir"
sudo chown -R root:root "$_target_dir"
sudo chmod -R 755 "$_target_dir"
print_success "Widevine installed to $_target_dir"
echo

# Cleanup
print_info "Cleaning up temporary files..."
cd /
rm -rf /tmp/chromium_widevine
print_success "Cleanup complete"
echo

# Final success message
echo "╔════════════════════════════════════════╗"
echo -e "║  ${GREEN}Installation completed successfully!${NC}  ║"
echo "╚════════════════════════════════════════╝"
echo
print_info "Next steps:"
echo -e "  ${CYAN}1.${NC} Completely close Helium browser (all windows)"
echo -e "  ${CYAN}2.${NC} Restart Helium"
echo -e "  ${CYAN}3.${NC} Check ${BLUE}chrome://components${NC} for Widevine status"
echo
print_warning "If DRM still doesn't work, try restarting your PC"
echo
echo -e "${MAGENTA}Have a lovely day :3${NC}"
