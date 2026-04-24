# Shadow-Browser
A high-tier custom implementation of the Mullvad Browser, routing all browser traffic through the ShadowNet. 

For Kali Linux/Parrot OS (other linux distros)

Note: For ultimate privacy and anonymity, route your whole system-wide traffic through ShadowNet and then use
the Shadow Browser. This will increase your OPSEC as you are jittering the jitter.

Shadow Browser: Signal Erasure Implementation

Shadow Browser is a custom implementation of the Mullvad Browser, hardened with the ShadowNet Engine. While standard privacy browsers only focuses on hiding your identity from websites, this implementation is engineered to erase your network signal from the infrastructure itself, defeating Global Passive Adversary (GPA) traffic analysis.

🛡️ Sovereign Integration

This project bridges the gap between industry-standard anti-fingerprinting and state-level metadata obfuscation.

ShadowNet Signal Erasure

    Temporal Jitter: 
    
    Integrated C-engines inject Micro/Macro IAT (Inter-Arrival Time) randomization between each 
    packets sent and their bursts, breaking the "mechanical" rhythm browser requests.

    Shape Entropy: 
    
    Randomized each MTU packet sizes to prevent protocol identification through size-profiling.

    DNS Requests/Data Entropy:
    
    Every dns requests received and sent has an entropy IAT. Fake dns data is sent to known companies as well
    to trick the observer.

    6-Hop Routing: 
    
    Forced 6-node circuit depth for exponential path anonymity.

    Killswitch:

    If tor, the cover traffic or the engine stops, the browser will be killed and exited immediately preventing any
    data leaks

    Mouse/Clicks/Scrolling/Typing:

    Added entropy IAT (Inter arrival time) to the key board typing input, added fake mouse movements and click delays and also
    added entropy IAT to the scrolling and fake scroll movements.

Mullvad Browser Foundation

    Custom Implementation: 
    
    Utilizes the official Mullvad Browser binary to inherit world-class 
    Anti-Fingerprinting (RFP) and security patches without modification to the core browser code.

    No-Telemetry: 
    
    Operates in a completely stripped environment, free of tracking scripts or phone-home telemetry.

    Volatile Isolation: 
    
    Runs entirely in /tmp/ RAM; all session data is physically erased on exit.

🛠️ Browser-Specific Isolation

Unlike the system-wide ShadowNet script, this implementation is surgically confined to the browser's environment:

    No Global Hooking: 
    
    Does not modify host iptables or system-wide /etc/resolv.conf.

    Isolated Binaries: 
    
    Uses unique process names (shadow_pulse, shadow_noise) to allow simultaneous use with other ShadowNet tools.
    (You can use shadownet system-wide while using the shadow browser, they won't conflict because
    the shadow browser's sockets are separte from the system-wide sockets)

🚀 Installation & Usage

Prerequisites: 

Linux, gcc, tor, and the Mullvad Browser portable binary in shadow-browser/.

Download the official stable mullvad browser portable binary for linux

https://mullvad.net/en/download/browser/linux

Place the mullvad-browser folder in the shadow-browser directory folder and then run this

    Permissions: chmod +x install.sh 

                 chmod +x uninstall.sh

                 sudo bash install.sh

    Now you can find the Shadow Browser in your applications menu
    or you can launch it in the /opt/shadow-browser directory

    ./shadow_launcher.sh or bash shadow_launcher.sh

    PLEASE DO NOT USE SUDO TO LAUNCH BROWSER!!!

⚖️ Sovereign Disclaimer

"There is nothing that the Sovereigns haven't seen." Shadow Browser is a tool for Unlinkability. By combining the "Mask" of Mullvad with the "Cloak" of ShadowNet, it ensures that your presence on the network is as invisible as your identity
