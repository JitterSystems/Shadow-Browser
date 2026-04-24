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
	
	# --- Check Dependencies ---
	if ! command -v xdotool &> /dev/null; then
		echo -e "${RED}[!] Error: xdotool is required for movement entropy. Install it with: sudo apt install xdotool${NC}"
		exit 1
		fi
		
		# --- Configuration ---
		SHADOW_DIR="/tmp/shadow_browser_session"
		TOR_DATA="$SHADOW_DIR/tor_data"
		BROWSER_PROFILE="$SHADOW_DIR/profile"
		BROWSER_BIN="/opt/shadow-browser/mullvad-browser/Browser/start-mullvad-browser"
		ICON_URL="/opt/shadow-browser/shadow.png"
		
		# --- SOVEREIGN CHECK: System-Wide Detection ---
		if [ -f "/dev/shm/shadownet_engine.pid" ]; then
			SYSTEM_WIDE=true
			echo -e "${BLUE}[*] ShadowNet System-Wide detected. Engaging Parasitic Mode...${NC}"
			
			# --- NUCLEAR PARASITIC WATCHDOG ---
			(
				while true; do
					# 1. Did the PID file vanish? OR
					# 2. Did the user execute the 'stop' command? (Bypasses the C-script's 68s exit delay)
					if [ ! -f "/dev/shm/shadownet_engine.pid" ] || pgrep -f "shadownet stop" > /dev/null; then
						# Target the actual Firefox/Mullvad window
						pkill -9 -f "ShadowBrowser" 2>/dev/null
						pkill -9 -f "mullvad" 2>/dev/null
						killall -9 start-mullvad-browser mullvad-browser 2>/dev/null
						
						# Perform the Teardown manually since we are about to kill the parent script
						sudo rm -rf "/tmp/shadow_browser_session"
						
						# Terminate the parent launcher script instantly to prevent ANY loop restarts
						kill -9 $$ 2>/dev/null
						exit
						fi
						sleep 0.2
						done
			) &
			else
				SYSTEM_WIDE=false
				echo -e "${BLUE}[*] No System-Wide shield detected. Initializing Local ShadowNet...${NC}"
				
				# --- Cleanup Previous Orphaned Sessions ---
				sudo killall -9 shadow_pulse shadow_noise tor start-mullvad-browser 2>/dev/null
				sudo rm -rf "$SHADOW_DIR"
				fi
				
				mkdir -p "$TOR_DATA"
				mkdir -p "$BROWSER_PROFILE"
				
				# --- Binary Isolation Logic ---
				echo -e "${GREEN}[+] Compiling Signal Erasure Engines (Isolated)...${NC}"
				gcc /opt/shadow-browser/heartbeat.c -o /opt/shadow-browser/shadow_pulse 2>/dev/null
				gcc /opt/shadow-browser/shadownet_engine.c -o /opt/shadow-browser/shadow_noise 2>/dev/null
				
				# --- Engagement ---
				if [ "$SYSTEM_WIDE" = false ]; then
					echo -e "${GREEN}[+] Engaging Temporal Jitter & UDP Noise...${NC}"
					sudo /opt/shadow-browser/shadow_noise 76.76.2.2 > /dev/null 2>&1 &
					sudo /opt/shadow-browser/shadow_pulse 1200 > /dev/null 2>&1 &
					
					PHASE1=$(( ( RANDOM % 21 ) + 10 ))
					echo -e "${BLUE}[*] Phase 1: Establishing Entry Tier (Nodes 1-3). Jitter: ${PHASE1}s...${NC}"
					sleep $PHASE1
					
					PHASE2=$(( ( RANDOM % 31 ) + 15 ))
					echo -e "${BLUE}[*] Phase 2: Extending to Exit Tier (Nodes 4-6). Entropy: ${PHASE2}s...${NC}"
					sleep $PHASE2
					
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
					sleep 3 
					fi
					
					cp /opt/shadow-browser/shadow_rules.js "$BROWSER_PROFILE/user.js"
					
					# --- BEHAVIORAL ENTROPY ENGINE (IAT Jitter) ---
					(
						while true; do
							if pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
								SLEEP_TIME=$(awk -v min=0.5 -v max=3.0 'BEGIN{srand(); print min+rand()*(max-min)}')
								sleep "$SLEEP_TIME"
								X_JIT=$(( (RANDOM % 3) - 1 ))
								Y_JIT=$(( (RANDOM % 3) - 1 ))
								xdotool mousemove_relative -- "$X_JIT" "$Y_JIT"
								RND=$((RANDOM % 100))
								if [ $RND -gt 90 ]; then
									DIR=$(( (RANDOM % 2) == 0 ? 4 : 5 ))
									xdotool click "$DIR"
									elif [ $RND -gt 85 ]; then
									xdotool key shift
									fi
									fi
									sleep 0.1
									done
					) &
					
					# --- Launch Loop ---
					while true; do
						if pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
							if [ "$SYSTEM_WIDE" = false ]; then
								if ! pgrep -f "shadow_noise" > /dev/null || ! pgrep -f "shadow_pulse" > /dev/null || ! pgrep -x "tor" > /dev/null; then
									sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
									break
									fi
									fi
									sleep 1
									continue
									fi
									
									echo -e "${BLUE}[!] ShadowNet Fully Active. Launching Shadow Browser...${NC}"
									export MOZ_APP_REMOTINGNAME="ShadowBrowser"
									"$BROWSER_BIN" --profile "$BROWSER_PROFILE" --no-remote --name "ShadowBrowser" --class "ShadowBrowser" --icon "$ICON_URL" > /dev/null 2>&1 &
									
									sleep 8
									
									while pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; do
										if [ "$SYSTEM_WIDE" = false ]; then
											if ! pgrep -f "shadow_noise" > /dev/null || ! pgrep -f "shadow_pulse" > /dev/null || ! pgrep -x "tor" > /dev/null; then
												sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
												break 2
												fi
												fi
												sleep 1
												done
												
												sleep 3
												if ! pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
													break
													fi
													done
													
													# --- Surgical Teardown ---
													if [ "$SYSTEM_WIDE" = false ]; then
														sudo killall -9 shadow_pulse shadow_noise tor 2>/dev/null 
														fi
														sudo rm -rf "$SHADOW_DIR"
														echo -e "${RED}[-] ATOMIC TEARDOWN COMPLETE.${NC}"
