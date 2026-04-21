#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>

void stop_shadownet() {
	printf("\033[1;31m[*] Tearing down ShadowNet Local Engines...\033[0m\n");
	
	// Kill only the specific processes spawned by this isolated instance
	system("pkill -f 'shadownet_engine'");
	system("pkill -f 'heartbeat'");
	system("pkill -f 'tor -f /tmp/shadow_torrc'");
	
	system("rm -f /tmp/shadow_torrc");
	printf("\033[1;31m[-] ShadowNet Deactivated. Traces cleared.\033[0m\n");
}

void start_shadownet() {
	if (access("./heartbeat", F_OK) == -1 || access("./shadownet_engine", F_OK) == -1) {
		printf("\033[0;31m[!] CRITICAL: heartbeat or shadownet_engine binaries missing. Compile them first.\033[0m\n");
		exit(1);
	}
	
	printf("\033[1;30m[*] Initializing Isolated ShadowNet Proxy...\033[0m\n");
	
	// 1. Create an isolated Tor configuration file in /tmp
	FILE *torrc = fopen("/tmp/shadow_torrc", "w");
	if (torrc) {
		fprintf(torrc, "SocksPort 127.0.0.1:9050\n");
		fprintf(torrc, "DataDirectory /tmp/shadow_tor_data\n");
		fprintf(torrc, "VirtualAddrNetworkIPv4 10.192.0.0/10\n");
		fprintf(torrc, "AutomapHostsOnResolve 1\n");
		fprintf(torrc, "LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6667,6697,8300\n");
		fprintf(torrc, "CircuitBuildTimeout 60\n");
		fprintf(torrc, "NumEntryGuards 3\n");
		fclose(torrc);
	} else {
		printf("\033[0;31m[!] Failed to write isolated proxy config.\033[0m\n");
		exit(1);
	}
	
	// 2. Start the localized 6-hop routing daemon
	printf("\033[1;34m[*] Establishing 6-Hop Circuitry on 127.0.0.1:9050...\033[0m\n");
	system("tor -f /tmp/shadow_torrc > /dev/null 2>&1 &");
	
	// 3. Start the Noise & Jitter Engines
	printf("\033[1;35m[*] Engaging Temporal Jitter & UDP Noise...\033[0m\n");
	system("sudo ./shadownet_engine 76.76.2.2 > /dev/null 2>&1 &");
	system("sudo ./heartbeat 1200 > /dev/null 2>&1 &");
	
	sleep(2);
	printf("\033[0;32m[+] ShadowNet Proxy Active.\033[0m\n");
	printf("\033[1;32m[+] Point your Shadow Browser to SOCKS5 proxy at 127.0.0.1:9050\033[0m\n");
}

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("\033[0;31mUsage: ./shadownet_isolated {start|stop}\033[0m\n");
		return 1;
	}
	
	if (strcmp(argv[1], "start") == 0) {
		start_shadownet();
	} else if (strcmp(argv[1], "stop") == 0) {
		stop_shadownet();
	} else {
		printf("\033[0;31mInvalid argument.\033[0m\n");
	}
	
	return 0;
}
