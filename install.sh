#!/bin/bash
# Shadow Browser System Installer (Portable GitHub Edition)

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
	echo -e "${RED}[!] Error: This script must be run as root (sudo bash install.sh)${NC}"
	exit 1
	fi
	
	INSTALL_DIR="/opt/shadow-browser"
	
	echo -e "${BLUE}[*] Installing OS dependencies (Including ImageMagick for Icon Injection)...${NC}"
	apt-get update -y
	DEBIAN_FRONTEND=noninteractive apt-get install -y tor gcc build-essential curl wget sudo psmisc imagemagick xdotool
	
	echo -e "${BLUE}[*] Creating Installation Directory ($INSTALL_DIR)...${NC}"
	mkdir -p "$INSTALL_DIR"
	
	if [[ ! -d "mullvad-browser" ]]; then
		echo -e "${RED}[!] Error: 'mullvad-browser' folder not found. Include the portable Linux browser in this directory for GitHub distribution.${NC}"
		exit 1
		fi
		
		echo -e "${BLUE}[*] Migrating source files and portable browser to /opt/...${NC}"
		cp -r mullvad-browser "$INSTALL_DIR/"
		cp heartbeat.c shadownet_engine.c shadow_rules.js shadow_launcher.sh shadow.png shadow-browser.desktop "$INSTALL_DIR/" 2>/dev/null
		
		cd "$INSTALL_DIR" || exit
		
		echo -e "${BLUE}[*] Compiling Noise & Jitter Engines...${NC}"
		gcc heartbeat.c -o heartbeat 2>/dev/null
		gcc shadownet_engine.c -o shadownet_engine 2>/dev/null
		
		echo -e "${BLUE}[*] Fetching and Forging Custom Shadow Browser Icons...${NC}"
		convert shadow.png -resize 256x256 /usr/share/pixmaps/shadow.png
		
		ICON_DIR="$INSTALL_DIR/mullvad-browser/Browser/browser/chrome/icons/default"
		mkdir -p "$ICON_DIR"
		
		convert shadow.png -resize 16x16 "$ICON_DIR/default16.png"
		convert shadow.png -resize 32x32 "$ICON_DIR/default32.png"
		convert shadow.png -resize 48x48 "$ICON_DIR/default48.png"
		convert shadow.png -resize 64x64 "$ICON_DIR/default64.png"
		convert shadow.png -resize 128x128 "$ICON_DIR/default128.png"
		
		sed -i 's/Name=Mullvad Browser/Name=Shadow Browser/g' "$INSTALL_DIR/mullvad-browser/Browser/application.ini" 2>/dev/null
		# FIX: Hardcodes the internal remoting name so the window manager doesn't see Mullvad
		sed -i 's/RemotingName=mullvadbrowser/RemotingName=ShadowBrowser/g' "$INSTALL_DIR/mullvad-browser/Browser/application.ini" 2>/dev/null
		
		echo -e "${BLUE}[*] Installing Application Shortcut...${NC}"
		DESKTOP_FILE="/usr/share/applications/shadow-browser.desktop"
		echo "[Desktop Entry]" > "$DESKTOP_FILE"
		echo "Version=1.0" >> "$DESKTOP_FILE"
		echo "Name=Shadow Browser" >> "$DESKTOP_FILE"
		echo "Comment=Routed via ShadowNet" >> "$DESKTOP_FILE"
		echo "Exec=bash -c \"cd /opt/shadow-browser && ./shadow_launcher.sh\"" >> "$DESKTOP_FILE"
		echo "Icon=shadow" >> "$DESKTOP_FILE"
		echo "Terminal=true" >> "$DESKTOP_FILE"
		echo "Type=Application" >> "$DESKTOP_FILE"
		echo "Categories=Network;WebBrowser;Security;" >> "$DESKTOP_FILE"
		# FIX: Removed the space to guarantee window manager matching
		echo "StartupWMClass=ShadowBrowser" >> "$DESKTOP_FILE"
		
		chmod 644 "$DESKTOP_FILE"
		
		echo -e "${BLUE}[*] Reclaiming Ownership for Normal User...${NC}"
		ACTUAL_USER=${SUDO_USER:-$USER}
		chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
		chmod -R 755 "$INSTALL_DIR"
		
		echo -e "${GREEN}[V] Installation Complete!${NC}"
		echo -e "${GREEN}[*] The original download folder can now be safely deleted. Shadow Browser is fully installed in /opt/.${NC}"
