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

// NO-FAILOVER KILLSWITCH
user_pref("network.proxy.failover_direct", false);
user_pref("network.proxy.no_proxies_on", "");

// --- SOVEREIGN HARDENING: WebGL & Canvas ---
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.resistFingerprinting.letterboxing", true);
user_pref("webgl.disabled", true);
user_pref("webgl.enable-debug-renderer-info", false);
user_pref("canvas.path.extract.max_retry", 0);
user_pref("dom.webaudio.enabled", false);
user_pref("privacy.reduceTimerPrecision", true);

user_pref("shell.state.wmclass", "ShadowBrowser");
