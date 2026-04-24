// Shadow Browser Strict Proxy Rules
user_pref("network.proxy.type", 1);
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_version", 5);
user_pref("network.proxy.socks_remote_dns", true);
user_pref("media.peerconnection.enabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);

// FIX: Force restarted profile to map to ShadowBrowser window class
user_pref("shell.state.wmclass", "ShadowBrowser");
