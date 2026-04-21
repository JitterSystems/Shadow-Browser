#!/bin/bash
# Shadow Browser Uninstaller (Leaves system Tor intact)

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
	echo -e "${RED}[!] Error: This script must be run as root (sudo ./uninstall.sh)${NC}"
	exit 1
	fi
	
	echo -e "${RED}[*] Terminating active ShadowNet proxies and noise engines...${NC}"
	# Only kill the specific Tor instance spawned by Shadow Browser, not system Tor
	pkill -f 'shadownet_engine' 2>/dev/null
	pkill -f 'heartbeat' 2>/dev/null
	pkill -f 'tor -f /tmp/shadow_browser_session/torrc' 2>/dev/null
	pkill -f 'shadow_launcher.sh' 2>/dev/null
	
	echo -e "${RED}[*] Erasing Application Files from /opt/...${NC}"
	rm -rf /opt/shadow-browser
	rm -rf /tmp/shadow_browser_session
	
	echo -e "${RED}[*] Erasing Desktop Shortcuts & System Icons...${NC}"
	rm -f /usr/share/applications/shadow-browser.desktop
	rm -f /usr/share/pixmaps/shadow-icon.jpg
	
	echo -e "${GREEN}[V] Shadow Browser and its temporary files have been completely removed.${NC}"
	echo -e "${BLUE}[*] Note: The host system's Tor installation remains untouched and fully operational.${NC}"
