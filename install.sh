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
	ICON_URL="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimg.buzzfeed.com%2Fbuzzfeed-static%2Fstatic%2F2022-10%2F10%2F17%2Fasset%2Fdc8b34d2141e%2Fsub-buzz-5585-1665423414-8.jpg"
	
	echo -e "${BLUE}[*] Installing OS dependencies (Including ImageMagick for Icon Injection)...${NC}"
	apt-get update -y
	DEBIAN_FRONTEND=noninteractive apt-get install -y tor gcc build-essential curl wget sudo psmisc imagemagick
	
	echo -e "${BLUE}[*] Creating Installation Directory ($INSTALL_DIR)...${NC}"
	mkdir -p "$INSTALL_DIR"
	
	if [[ ! -d "mullvad-browser" ]]; then
		echo -e "${RED}[!] Error: 'mullvad-browser' folder not found. Include the portable Linux browser in this directory for GitHub distribution.${NC}"
		exit 1
		fi
		
		echo -e "${BLUE}[*] Migrating source files and portable browser to /opt/...${NC}"
		cp -r mullvad-browser "$INSTALL_DIR/"
		cp heartbeat.c shadownet_engine.c shadow_rules.js shadow_launcher.sh "$INSTALL_DIR/"
		
		cd "$INSTALL_DIR" || exit
		
		echo -e "${BLUE}[*] Compiling Noise & Jitter Engines...${NC}"
		gcc heartbeat.c -o heartbeat 2>/dev/null
		gcc shadownet_engine.c -o shadownet_engine 2>/dev/null
		
		echo -e "${BLUE}[*] Fetching and Forging Custom Shadow Browser Icons...${NC}"
		wget -qO /tmp/shadow-raw.jpg "$ICON_URL"
		convert /tmp/shadow-raw.jpg -resize 256x256 /usr/share/pixmaps/shadow-icon.png
		
		ICON_DIR="$INSTALL_DIR/mullvad-browser/Browser/browser/chrome/icons/default"
		mkdir -p "$ICON_DIR"
		
		convert /tmp/shadow-raw.jpg -resize 16x16 "$ICON_DIR/default16.png"
		convert /tmp/shadow-raw.jpg -resize 32x32 "$ICON_DIR/default32.png"
		convert /tmp/shadow-raw.jpg -resize 48x48 "$ICON_DIR/default48.png"
		convert /tmp/shadow-raw.jpg -resize 64x64 "$ICON_DIR/default64.png"
		convert /tmp/shadow-raw.jpg -resize 128x128 "$ICON_DIR/default128.png"
		
		sed -i 's/Name=Mullvad Browser/Name=Shadow Browser/g' "$INSTALL_DIR/mullvad-browser/Browser/application.ini" 2>/dev/null
		
		echo -e "${BLUE}[*] Installing Application Shortcut...${NC}"
		DESKTOP_FILE="/usr/share/applications/shadow-browser.desktop"
		echo "[Desktop Entry]" > "$DESKTOP_FILE"
		echo "Version=1.0" >> "$DESKTOP_FILE"
		echo "Name=Shadow Browser" >> "$DESKTOP_FILE"
		echo "Comment=Routed via ShadowNet" >> "$DESKTOP_FILE"
		echo "Exec=bash -c \"cd /opt/shadow-browser && ./shadow_launcher.sh\"" >> "$DESKTOP_FILE"
		echo "Icon=shadow-icon" >> "$DESKTOP_FILE"
		echo "Terminal=true" >> "$DESKTOP_FILE"
		echo "Type=Application" >> "$DESKTOP_FILE"
		echo "Categories=Network;WebBrowser;Security;" >> "$DESKTOP_FILE"
		echo "StartupWMClass=Shadow Browser" >> "$DESKTOP_FILE"
		
		chmod 644 "$DESKTOP_FILE"
		
		echo -e "${BLUE}[*] Reclaiming Ownership for Normal User...${NC}"
		# Use SUDO_USER to dynamically find who actually ran the script
		ACTUAL_USER=${SUDO_USER:-$USER}
		chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
		chmod -R 755 "$INSTALL_DIR"
		
		echo -e "${GREEN}[V] Installation Complete!${NC}"
		echo -e "${GREEN}[*] The original download folder can now be safely deleted. Shadow Browser is fully installed in /opt/.${NC}" "start-mullvad-browser"
