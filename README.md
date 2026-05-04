# Shadow-Browser
A high-tier custom implementation of the Mullvad Browser, that uses the systemwide ShadowNet as it's only
connection to the internet.

NOTE! This browser can no longer operate if ShadowNet is not running system-wide. Start ShadowNet first and then open the Shadow Browser.

For Kali Linux/Parrot OS (other linux distros)

Shadow Browser: Signal Erasure Implementation

Shadow Browser is a custom implementation of the Mullvad Browser, hardened to use the ShadowNet Engine. While standard privacy browsers only focuses on hiding your identity from websites, this implementation is engineered to erase your network signal from the infrastructure itself, defeating Global Passive Adversary (GPA) traffic analysis.

🛡️ Sovereign Integration

This project bridges the gap between industry-standard anti-fingerprinting and state-level metadata obfuscation.

ShadowNet Signal Erasure

Everything the ShadowNet is doing, will automatically anonymize the browser. The browser's added extra security features are just
to further improve it (browser wise)



    Killswitch:

    If the ShadowNet ever stops or gets corrupted, the Browser's internet will be killed immediately preventing any sort of leaks.

    WEB-GL protection & Canvas Spoofing:

    You get a new canvas fingerprinting identity and web-gl is set to read-only to prevent it snitching on your hardware

    Screen Resolution Protection:

    A standard viewpoint is assigned to you, even if you maximize the browser it'll not leak your computer's actual
    screen resolution.

    Generic Linux:

    reports as a hardened linux machine.

    Using this browser, will make you a ghost when browsing due to ShadowNet running system-wide and because of the current Mullvad anti-fingerprint
    protection and added canvas/web-gl and screen resolution protection. All of the features of ShadowNet like the packet randomization, jitters, lokinet cover traffic
    etc are all anonymizing the browser by default.

    
    
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

    Can you visit .onion websites?

    yes you can!

⚖️ Sovereign Disclaimer

"There is nothing that the Sovereigns haven't seen." Shadow Browser is a tool for Unlinkability. By combining the "Mask" of Mullvad with the "Cloak" of ShadowNet, it ensures that your presence on the network is as invisible as your identity
