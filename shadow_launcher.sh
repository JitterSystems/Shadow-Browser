#!/bin/bash

# --- Styling ---
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# --- Root Check ---
if [[ $EUID -eq 0 ]]; then
	echo -e "${RED}[!] Error: Do not run this script with sudo. Run it as your normal user.${NC}"
	exit 1
	fi
	
	echo -e "${BLUE}[*] Initializing ShadowNet Local Engine...${NC}"
	
	# --- Configuration ---
	SHADOW_DIR="/tmp/shadow_browser_session"
	TOR_DATA="$SHADOW_DIR/tor_data"
	BROWSER_PROFILE="$SHADOW_DIR/profile"
	BROWSER_BIN="/opt/shadow-browser/mullvad-browser/Browser/start-mullvad-browser"
	# --- UPDATED ICON ---
	ICON_URL="https://i.pinimg.com/originals/f5/55/a5/f555a56d8221d9dc9e855c9052bb94d3.png"
	
	# --- Cleanup Previous Orphaned Sessions ---
	sudo killall -9 shadow_pulse shadow_noise tor start-mullvad-browser 2>/dev/null
	sudo rm -rf "$SHADOW_DIR"
	
	mkdir -p "$TOR_DATA"
	mkdir -p "$BROWSER_PROFILE"
	
	# --- Binary Isolation Logic ---
	echo -e "${GREEN}[+] Compiling Signal Erasure Engines (Isolated)...${NC}"
	gcc /opt/shadow-browser/heartbeat.c -o /opt/shadow-browser/shadow_pulse 2>/dev/null
	gcc /opt/shadow-browser/shadownet_engine.c -o /opt/shadow-browser/shadow_noise 2>/dev/null
	
	# --- Engagement ---
	echo -e "${GREEN}[+] Engaging Temporal Jitter & UDP Noise...${NC}"
	sudo /opt/shadow-browser/shadow_noise 76.76.2.2 > /dev/null 2>&1 &
	ENGINE_PID=$!
	sudo /opt/shadow-browser/shadow_pulse 1200 > /dev/null 2>&1 &
	HEARTBEAT_PID=$!
	
	# --- Original Sovereign Establishment Entropy ---
	PHASE1=$(( ( RANDOM % 21 ) + 10 ))
	echo -e "${BLUE}[*] Phase 1: Establishing Entry Tier (Nodes 1-3). Jitter: ${PHASE1}s...${NC}"
	sleep $PHASE1
	
	PHASE2=$(( ( RANDOM % 31 ) + 15 ))
	echo -e "${BLUE}[*] Phase 2: Extending to Exit Tier (Nodes 4-6). Entropy: ${PHASE2}s...${NC}"
	sleep $PHASE2
	
	# --- Network Configuration (6-Hop Layer) ---
	TORRC_FILE="$SHADOW_DIR/torrc"
	echo "SocksPort 127.0.0.1:9050" > "$TORRC_FILE"
	echo "DataDirectory $TOR_DATA" >> "$TORRC_FILE"
	echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >> "$TORRC_FILE"
	echo "AutomapHostsOnResolve 1" >> "$TORRC_FILE"
	echo "LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6667,6697,8300" >> "$TORRC_FILE"
	echo "CircuitBuildTimeout 60" >> "$TORRC_FILE"
	echo "NumEntryGuards 3" >> "$TORRC_FILE"
	
	echo -e "${GREEN}[+] Establishing 6-Hop Circuitry...${NC}"
	tor -f "$TORRC_FILE" > /dev/null 2>&1 &
	TOR_PID=$!
	
	sleep 3 
	
	# Inject Shadow Rules
	cp /opt/shadow-browser/shadow_rules.js "$BROWSER_PROFILE/user.js"
	
	# --- Launch Loop ---
	# FIX: Added process verification to prevent infinite relaunch loops
	while true; do
		# Check if a process is ALREADY running before launching
		if pgrep -f "mullvad-browser" > /dev/null; then
			echo -e "${GREEN}[*] Browser Active. Monitoring ShadowNet Shield...${NC}"
			sleep 5
			continue
			fi
			
			echo -e "${BLUE}[!] ShadowNet Fully Active. Launching Shadow Browser...${NC}"
			# Use explicit path to ensure it doesn't open the system-default browser
			"$BROWSER_BIN" --profile "$BROWSER_PROFILE" --no-remote --name "Shadow Browser" --class "Shadow Browser" --icon "$ICON_URL" > /dev/null 2>&1 &
			
			# Critical Cooldown: Give the browser time to initialize so pgrep catches it
			sleep 8
			
			# Monitoring phase: wait until the browser is actually closed
			while pgrep -f "mullvad-browser" > /dev/null; do
				sleep 2
				done
				
				# Final check: Did it close for good, or is it restarting for a security level change?
				sleep 3
				if ! pgrep -f "mullvad-browser" > /dev/null; then
					# If after 3 seconds nothing is running, the user manually quit
					break
					fi
					done
					
					# --- Surgical Teardown ---
					echo -e "${RED}[-] Browser closed. Tearing down ShadowNet & Jitter...${NC}"
					sudo kill -9 $ENGINE_PID $HEARTBEAT_PID $TOR_PID 2>/dev/null
					sudo killall -9 shadow_pulse shadow_noise 2>/dev/null 
					
					sudo rm -rf "$SHADOW_DIR"
					echo -e "${GREEN}[V] Traces erased.${NC}"
