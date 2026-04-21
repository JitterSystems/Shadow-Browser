// Shadow Browser Strict Proxy Rules
// Forces all traffic through the local ShadowNet SOCKS5 proxy

// Enable SOCKS v5 proxy on 127.0.0.1:9050
user_pref("network.proxy.type", 1);
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_version", 5);

// CRITICAL: Force DNS queries through the proxy to prevent leaks
user_pref("network.proxy.socks_remote_dns", true);

// Disable WebRTC to prevent IP discovery via STUN/TURN
user_pref("media.peerconnection.enabled", false);

// Disable telemetry and background connections
user_pref("toolkit.telemetry.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
