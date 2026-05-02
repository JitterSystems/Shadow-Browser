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

# --- SOVEREIGN PERSONA & HARDWARE NOISE GENERATOR ---
SPEED_ROLL=$(( ( RANDOM % 3 ) + 1 ))
case $SPEED_ROLL in
1) PERSONA="Aggressive"; MIN_IAT="0.2"; MAX_IAT="1.2"; JIT_RANGE="3"; DRIFT="0.0001"; ROT_MIN=15; ROT_MAX=45 ;;
2) PERSONA="Deliberate"; MIN_IAT="0.8"; MAX_IAT="2.5"; JIT_RANGE="1"; DRIFT="0.0005"; ROT_MIN=60; ROT_MAX=180 ;;
3) PERSONA="Stochastic"; MIN_IAT="0.4"; MAX_IAT="4.0"; JIT_RANGE="2"; DRIFT="0.0002"; ROT_MIN=10; ROT_MAX=300 ;;
esac

# --- SOVEREIGN CHECK: System-Wide Detection ---
if [ -f "/dev/shm/shadownet_engine.pid" ]; then
    SYSTEM_WIDE=true
    echo -e "${BLUE}[*] ShadowNet System-Wide detected ($PERSONA Persona). Engaging Parasitic Mode...${NC}"
else
    SYSTEM_WIDE=false
    echo -e "${BLUE}[*] No System-Wide shield detected ($PERSONA Persona). Initializing Local ShadowNet...${NC}"
    sudo killall -9 shadow_pulse shadow_noise tor lokinet start-mullvad-browser 2>/dev/null
    sudo rm -rf "$SHADOW_DIR"
fi

mkdir -p "$TOR_DATA"
mkdir -p "$BROWSER_PROFILE"

# --- WIPE AND OVERRIDE LOKINET.INI ---
sudo bash -c 'cat <<EOF > /var/lib/lokinet/lokinet.ini
[network]
enabled=true

[dns]


[router]
EOF'

# --- Binary Isolation Logic ---
echo -e "${GREEN}[+] Compiling Signal Erasure Engines (Isolated)...${NC}"
gcc /opt/shadow-browser/heartbeat.c -o /opt/shadow-browser/shadow_pulse 2>/dev/null
gcc /opt/shadow-browser/shadownet_engine.c -o /opt/shadow-browser/shadow_noise 2>/dev/null

# --- Engagement ---
if [ "$SYSTEM_WIDE" = false ]; then
    echo -e "${GREEN}[+] Engaging Temporal Jitter & UDP Noise...${NC}"
    sudo /opt/shadow-browser/shadow_noise 76.76.2.2 > /dev/null 2>&1 &

    # EXTRA ENTROPY IAT DELAY (1)
    IAT_PRE_PHASE1=$(( ( RANDOM % 10 ) + 5 ))
    echo -e "${BLUE}[*] Extra entropy IAT delay: ${IAT_PRE_PHASE1}s...${NC}"
    sleep $IAT_PRE_PHASE1

    # ADDITIONAL ENTROPY IAT (2)
    ADD_IAT1=$(( ( RANDOM % 8 ) + 3 ))
    echo -e "${BLUE}[*] Additional entropy IAT delay: ${ADD_IAT1}s...${NC}"
    sleep $ADD_IAT1

    # START LOKINET SERVICES
    echo -e "${BLUE}[*] Starting Lokinet Services...${NC}"
    sudo systemctl start lokinet

    # WAIT FOR LOKITUN0 INTERFACE
    while ! ip addr show lokitun0 &> /dev/null; do sleep 1; done

    sudo /opt/shadow-browser/shadow_pulse 1400 > /dev/null 2>&1 &

    # ADDITIONAL ENTROPY IAT (3)
    ADD_IAT2=$(( ( RANDOM % 12 ) + 4 ))
    echo -e "${BLUE}[*] Additional entropy IAT delay: ${ADD_IAT2}s...${NC}"
    sleep $ADD_IAT2

    PHASE1=$(( ( RANDOM % 21 ) + 10 ))
    echo -e "${BLUE}[*] Phase 1: Establishing Entry Tier (Nodes 1-3). Jitter: ${PHASE1}s...${NC}"
    sleep $PHASE1

    IAT_PRE_PHASE2=$(( ( RANDOM % 15 ) + 5 ))
    echo -e "${BLUE}[*] Extra entropy IAT delay: ${IAT_PRE_PHASE2}s...${NC}"
    sleep $IAT_PRE_PHASE2

    PHASE2=$(( ( RANDOM % 31 ) + 15 ))
    echo -e "${BLUE}[*] Phase 2: Extending to Exit Tier (Nodes 4-6). Entropy: ${PHASE2}s...${NC}"
    sleep $PHASE2

    # FRESH TORRC GENERATION
    TORRC_FILE="$SHADOW_DIR/torrc"
    {
        echo "SocksPort 127.0.0.1:9050 IsolateDestAddr IsolateDestPort IsolateClientAddr IsolateClientProtocol IsolateSOCKSAuth"
        echo "ControlPort 127.0.0.1:9051"
        echo "CookieAuthentication 0"
        echo "DataDirectory $TOR_DATA"
        echo "VirtualAddrNetworkIPv4 10.192.0.0/10"
        echo "AutomapHostsOnResolve 1"
        echo "LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6667,6697,8300"
        echo "CircuitBuildTimeout 60"
        echo "NumEntryGuards 3"
        echo "EnforceDistinctSubnets 1"
        echo "NewCircuitPeriod 1"
        echo "MaxCircuitDirtiness 1"
        echo "CircuitPadding 1"
        echo "ConnectionPadding 1"
        echo "ReducedConnectionPadding 0"
        echo "ReducedCircuitPadding 0"
        echo "UseBridges 1"
        echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy"
        echo "Bridge obfs4 89.116.48.119:32278 EB1331E3372F12A1B42D2A8ECAF7064251C56B66 cert=pfjOWyOhh7bEcZUtKekBFbBPKSnhWjS4yyFG+/n0Foq3Bq6m8gsLecMHBf9K01a/wLiNAQ iat-mode=0"
        echo "Bridge obfs4 100.8.170.63:50164 FBA329BA4F5FE648456C3A28BBAA3C7EBD118E08 cert=DKA6xS0N6c4I1CFVmWc/qgAEhPBgR/dPQyXhbkjt082Ka2xmq1pwSUpCPt626uuKW2Z1TA iat-mode=0"
    } > "$TORRC_FILE"

    echo -e "${GREEN}[+] Establishing 6-Hop Circuitry...${NC}"
    tor -f "$TORRC_FILE" > /dev/null 2>&1 &
    sleep 3
fi

# --- MSS CLAMPING ---
sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1100 2>/dev/null

# --- SOVEREIGN BROWSER HARDENING ---
cp /opt/shadow-browser/shadow_rules.js "$BROWSER_PROFILE/user.js"

# --- BEHAVIORAL ENTROPY ENGINE ---
(
    while true; do
        if pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
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
    if pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
        if [ "$SYSTEM_WIDE" = false ]; then
            # VERIFYING ALL DEFENSIVE PILLARS 1000 TIMES PER SECOND
            if ! pgrep -f "shadow_noise" > /dev/null || ! pgrep -f "shadow_pulse" > /dev/null || ! pgrep -x "tor" > /dev/null || ! systemctl is-active --quiet lokinet; then
                echo -e "${RED}[!] ATOMIC TEARDOWN: ENGINE FAILURE DETECTED.${NC}"
                sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
                sudo systemctl stop lokinet
                break
            fi
        fi
        sleep 0.001
        continue
    fi

    echo -e "${BLUE}[!] ShadowNet Fully Active. Launching Shadow Browser...${NC}"
    export MOZ_APP_REMOTINGNAME="ShadowBrowser"
    "$BROWSER_BIN" --profile "$BROWSER_PROFILE" --no-remote --name "ShadowBrowser" --class "ShadowBrowser" --icon "$ICON_URL" > /dev/null 2>&1 &

    sleep 8

    while pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; do
        if [ "$SYSTEM_WIDE" = false ]; then
            if ! pgrep -f "shadow_noise" > /dev/null || ! pgrep -f "shadow_pulse" > /dev/null || ! pgrep -x "tor" > /dev/null || ! systemctl is-active --quiet lokinet; then
                sudo killall -9 start-mullvad-browser mullvad-browser tor 2>/dev/null
                sudo systemctl stop lokinet
                break 2
            fi
        fi
        sleep 0.001
    done

    if ! pgrep -f "/opt/shadow-browser/mullvad-browser" > /dev/null; then
        break
    fi
done

# --- Surgical Teardown ---
if [ "$SYSTEM_WIDE" = false ]; then
    sudo killall -9 shadow_pulse shadow_noise tor 2>/dev/null
    sudo systemctl stop lokinet
    pkill -f "xdotool" 2>/dev/null
fi
sudo iptables -t mangle -D POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1100 2>/dev/null
sudo rm -rf "$SHADOW_DIR"
echo -e "${RED}[-] ATOMIC TEARDOWN COMPLETE.${NC}"
