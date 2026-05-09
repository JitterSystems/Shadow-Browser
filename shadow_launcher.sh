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
        
        # --- FIXED TIMING CONFIGURATION ---
        PERSONA="Standard"
        MIN_IAT="0.5"
        MAX_IAT="1.5"
        JIT_RANGE="2"
        DRIFT="0.0002"
        
        # --- STRICT SOVEREIGN CHECK: System-Wide Detection ---
        if [ -f "/dev/shm/shadownet_engine.pid" ]; then
            SYSTEM_WIDE=true
            echo -e "${BLUE}[*] ShadowNet System-Wide detected ($PERSONA Persona). Engaging Parasitic Mode...${NC}"
            else
                # STRICT ENFORCEMENT: EXIT IF NOT DETECTED
                echo -e "${RED}[!] CRITICAL ERROR: System-Wide ShadowNet NOT DETECTED.${NC}"
                echo -e "${RED}[!] Security Protocol: Browser launch aborted to prevent signal leakage.${NC}"
                exit 1
                fi
                
                mkdir -p "$TOR_DATA"
                mkdir -p "$BROWSER_PROFILE"
                
                # --- WIPE AND OVERRIDE LOKINET.INI ---
                # Fixed syntax using printf to eliminate here-document warnings
                printf "[network]\nenabled=true\n\n[dns]\n\n\n[router]\n" | sudo tee /var/lib/lokinet/lokinet.ini > /dev/null
                
                # --- Binary Isolation Logic ---
                echo -e "${GREEN}[+] Compiling Signal Erasure Engines (Isolated)...${NC}"
                gcc /opt/shadow-browser/heartbeat.c -o /opt/shadow-browser/shadow_pulse 2>/dev/null
                gcc /opt/shadow-browser/shadownet_engine.c -o /opt/shadow-browser/shadow_noise 2>/dev/null
                
                # --- Engagement ---
                if [ "$SYSTEM_WIDE" = false ]; then
                    echo -e "${GREEN}[+] Engaging Temporal Jitter & UDP Noise...${NC}"
                    sudo /opt/shadow-browser/shadow_noise 76.76.2.2 > /dev/null 2>&1 &
                    fi
                    
                    # --- MSS CLAMPING ---
                    sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1100 2>/dev/null
                    
                    # --- SOVEREIGN BROWSER HARDENING ---
                    cp /opt/shadow-browser/shadow_rules.js "$BROWSER_PROFILE/user.js"
                    
                    # --- BEHAVIORAL ENTROPY ENGINE ---
                    (
                        while true; do
                            if pgrep -f "mullvad-browser" > /dev/null; then
                                sleep "$DRIFT"
                                SLEEP_TIME=$(awk -v min=$MIN_IAT -v max=$MAX_IAT 'BEGIN{srand(); print min+rand()*(max-min)}')
                                sleep "$SLEEP_TIME"
                                X_JIT=$(( (RANDOM % (JIT_RANGE * 2 + 1)) - JIT_RANGE ))
                                Y_JIT=$(( (RANDOM % (JIT_RANGE * 2 + 1)) - JIT_RANGE ))
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
                    
                    # --- Ultra-High Frequency Launch Loop (1ms Check) ---
                    while true; do
                        if pgrep -f "mullvad-browser" > /dev/null; then
                            if [ ! -f "/dev/shm/shadownet_engine.pid" ]; then
                                echo -e "${RED}[!] ATOMIC TEARDOWN: SYSTEM SHADOWNET LOST.${NC}"
                                sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
                                break
                                fi
                                sleep 0.001
                                continue
                                fi
                                
                                echo -e "${BLUE}[!] ShadowNet Fully Active. Launching Shadow Browser...${NC}"
                                export MOZ_APP_REMOTINGNAME="ShadowBrowser"
                                "$BROWSER_BIN" --profile "$BROWSER_PROFILE" --no-remote --name "ShadowBrowser" --class "ShadowBrowser" --icon "$ICON_URL" > /dev/null 2>&1 &
                                
                                # Increased sleep to ensure the browser binary has time to initialize before the check loop starts
                                sleep 5
                                
                                while pgrep -f "mullvad-browser" > /dev/null; do
                                    if [ ! -f "/dev/shm/shadownet_engine.pid" ]; then
                                        sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
                                        break 2
                                        fi
                                        sleep 0.1
                                        done
                                        
                                        # Check if the process really died or just hasn't registered yet
                                        if ! pgrep -f "mullvad-browser" > /dev/null; then
                                            break
                                            fi
                                            done
                                            
                                            # --- Surgical Teardown ---
                                            pkill -f "xdotool" 2>/dev/null
                                            sudo iptables -t mangle -D POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1100 2>/dev/null
                                            sudo rm -rf "$SHADOW_DIR"
                                            echo -e "${RED}[-] ATOMIC TEARDOWN COMPLETE.${NC}"
